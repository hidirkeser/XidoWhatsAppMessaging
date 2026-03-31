using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Minion.Infrastructure.Persistence;

namespace Minion.Infrastructure.Middleware;

/// <summary>
/// Reads X-Api-Key + X-Api-Secret headers, validates against OrganizationApiKeys table,
/// and sets HttpContext.Items["OrganizationId"] for downstream external API controllers.
/// JWT authentication is unaffected — this runs in parallel with the JWT pipeline.
/// </summary>
public class ApiKeyAuthMiddleware
{
    private readonly RequestDelegate _next;

    public ApiKeyAuthMiddleware(RequestDelegate next) => _next = next;

    public async Task InvokeAsync(HttpContext context)
    {
        if (context.Request.Headers.TryGetValue("X-Api-Key", out var keyIdHeader) &&
            context.Request.Headers.TryGetValue("X-Api-Secret", out var secretHeader))
        {
            var keyId  = keyIdHeader.ToString();
            var secret = secretHeader.ToString();

            var db = context.RequestServices.GetRequiredService<ApplicationDbContext>();

            var apiKey = await db.OrganizationApiKeys
                .FirstOrDefaultAsync(k => k.KeyId == keyId && k.IsActive);

            if (apiKey != null && BCrypt.Net.BCrypt.Verify(secret, apiKey.SecretHash))
            {
                context.Items["OrganizationId"] = apiKey.OrganizationId;

                // Update usage stats (fire and forget — don't block the request)
                apiKey.LastUsedAt   = DateTime.UtcNow;
                apiKey.RequestCount += 1;
                _ = db.SaveChangesAsync();
            }
        }

        await _next(context);
    }
}

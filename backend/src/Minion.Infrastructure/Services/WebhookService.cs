using System.Net.Http.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services;

public class WebhookService : IWebhookService
{
    private readonly IApplicationDbContext _context;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<WebhookService> _logger;

    public WebhookService(
        IApplicationDbContext context,
        IHttpClientFactory httpClientFactory,
        ILogger<WebhookService> logger)
    {
        _context = context;
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public async Task SendDelegationAcceptedAsync(
        Guid organizationId, Guid delegationId, string verificationCode, CancellationToken ct = default)
    {
        var org = await _context.Organizations
            .FirstOrDefaultAsync(o => o.Id == organizationId, ct);

        if (org?.CallbackUrl is null) return;

        var payload = new
        {
            @event = "delegation.accepted",
            organizationId,
            delegationId,
            verificationCode,
            timestamp = DateTime.UtcNow
        };

        _ = Task.Run(async () =>
        {
            try
            {
                var client = _httpClientFactory.CreateClient("webhook");
                var response = await client.PostAsJsonAsync(org.CallbackUrl, payload);
                if (!response.IsSuccessStatusCode)
                    _logger.LogWarning("Webhook to {Url} returned {Status}", org.CallbackUrl, response.StatusCode);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Webhook delivery failed for org {OrgId}", organizationId);
            }
        });
    }
}

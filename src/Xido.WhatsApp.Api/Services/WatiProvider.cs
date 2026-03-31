using System.Globalization;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Xido.WhatsApp.Api.Services;

public class WatiProvider(
    HttpClient httpClient,
    IConfiguration config,
    ILogger<WatiProvider> logger) : IWhatsAppProvider
{
    public string ProviderName => "Wati";

    public async Task<(string status, string? externalId, string? error)> SendAsync(
        string toPhone, string? recipientName, string body, CancellationToken ct = default)
    {
        var endpoint = config["WhatsApp:Wati:ApiEndpoint"]?.TrimEnd('/')
            ?? throw new InvalidOperationException("WhatsApp:Wati:ApiEndpoint not configured");
        var token = config["WhatsApp:Wati:BearerToken"]
            ?? throw new InvalidOperationException("WhatsApp:Wati:BearerToken not configured");

        try
        {
            var cleanPhone = toPhone.TrimStart('+');
            var url        = $"{endpoint}/api/v1/sendSessionMessage/{cleanPhone}";

            using var request = new HttpRequestMessage(HttpMethod.Post, url);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            request.Content = JsonContent.Create(new { messageText = body });

            var response     = await httpClient.SendAsync(request, ct);
            var responseBody = await response.Content.ReadAsStringAsync(ct);

            if (response.IsSuccessStatusCode)
            {
                logger.LogInformation("[Wati] Sent to {Phone}", toPhone);
                return ("sent", Truncate(responseBody, 200), null);
            }

            logger.LogError("[Wati] Failed to {Phone}: {Body}", toPhone, responseBody);
            return ("failed", null, Truncate(responseBody, 1000));
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "[Wati] Exception sending to {Phone}", toPhone);
            return ("failed", null, Truncate(ex.Message, 1000));
        }
    }

    private static string Truncate(string s, int max) => s.Length > max ? s[..max] : s;
}

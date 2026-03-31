using System.Net.Http.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Xido.WhatsApp.Api.Services;

public class AiSensyProvider(
    HttpClient httpClient,
    IConfiguration config,
    ILogger<AiSensyProvider> logger) : IWhatsAppProvider
{
    private const string ApiUrl = "https://backend.aisensy.com/campaign/t1/api/v2";

    public string ProviderName => "AiSensy";

    public async Task<(string status, string? externalId, string? error)> SendAsync(
        string toPhone, string? recipientName, string body,
        string? mediaUrl = null, CancellationToken ct = default)
    {
        if (mediaUrl != null)
            logger.LogWarning("[AiSensy] MMS not supported — mediaUrl ignored for {Phone}", toPhone);

        var apiKey = config["WhatsApp:AiSensy:ApiKey"]
            ?? throw new InvalidOperationException("WhatsApp:AiSensy:ApiKey not configured");
        var campaignName = config["WhatsApp:AiSensy:CampaignName"]
            ?? throw new InvalidOperationException("WhatsApp:AiSensy:CampaignName not configured");

        try
        {
            var payload = new
            {
                apiKey,
                campaignName,
                destination = toPhone,
                userName    = recipientName ?? toPhone,
            };

            var response     = await httpClient.PostAsJsonAsync(ApiUrl, payload, ct);
            var responseBody = await response.Content.ReadAsStringAsync(ct);

            if (response.IsSuccessStatusCode)
            {
                logger.LogInformation("[AiSensy] Sent to {Phone}", toPhone);
                return ("sent", Truncate(responseBody, 200), null);
            }

            logger.LogError("[AiSensy] Failed to {Phone}: {Body}", toPhone, responseBody);
            return ("failed", null, Truncate(responseBody, 1000));
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "[AiSensy] Exception sending to {Phone}", toPhone);
            return ("failed", null, Truncate(ex.Message, 1000));
        }
    }

    private static string Truncate(string s, int max) => s.Length > max ? s[..max] : s;
}

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Xido.WhatsApp.Api.Services;

/// <summary>
/// Routes WhatsApp send calls to the provider configured in WhatsApp:Provider.
/// Supported values: AiSensy, Wati, Twilio
/// MMS (mediaUrl) is only supported by Twilio.
/// </summary>
public class WhatsAppRouter(
    AiSensyProvider aiSensy,
    WatiProvider    wati,
    TwilioProvider  twilio,
    IConfiguration  config,
    ILogger<WhatsAppRouter> logger)
{
    public IWhatsAppProvider GetProvider()
    {
        var name = config["WhatsApp:Provider"] ?? "AiSensy";

        return name.ToLowerInvariant() switch
        {
            "wati"   => wati,
            "twilio" => twilio,
            _        => aiSensy,
        };
    }

    public async Task<(string status, string? externalId, string? error)> SendAsync(
        string toPhone, string? recipientName, string body,
        string? mediaUrl = null, CancellationToken ct = default)
    {
        var provider = GetProvider();
        logger.LogInformation("[Router] Provider: {Provider} → {Phone} | MMS: {HasMedia}",
            provider.ProviderName, toPhone, mediaUrl != null);
        return await provider.SendAsync(toPhone, recipientName, body, mediaUrl, ct);
    }
}

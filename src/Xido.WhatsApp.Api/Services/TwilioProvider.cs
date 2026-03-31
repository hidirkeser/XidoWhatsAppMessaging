using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Twilio.Types;

namespace Xido.WhatsApp.Api.Services;

public class TwilioProvider(
    IConfiguration config,
    ILogger<TwilioProvider> logger) : IWhatsAppProvider
{
    public string ProviderName => "Twilio";

    public async Task<(string status, string? externalId, string? error)> SendAsync(
        string toPhone, string? recipientName, string body,
        string? mediaUrl = null, CancellationToken ct = default)
    {
        var accountSid = config["WhatsApp:Twilio:AccountSid"]
            ?? throw new InvalidOperationException("WhatsApp:Twilio:AccountSid not configured");
        var authToken = config["WhatsApp:Twilio:AuthToken"]
            ?? throw new InvalidOperationException("WhatsApp:Twilio:AuthToken not configured");
        var from = config["WhatsApp:Twilio:From"]
            ?? throw new InvalidOperationException("WhatsApp:Twilio:From not configured");

        try
        {
            TwilioClient.Init(accountSid, authToken);

            var createParams = new CreateMessageOptions(
                new PhoneNumber($"whatsapp:{toPhone}"))
            {
                From = new PhoneNumber(from.StartsWith("whatsapp:") ? from : $"whatsapp:{from}"),
                Body = body,
            };

            // MMS — attach media if provided
            if (!string.IsNullOrWhiteSpace(mediaUrl))
            {
                createParams.MediaUrl = [new Uri(mediaUrl)];
                logger.LogInformation("[Twilio] Attaching media: {MediaUrl}", mediaUrl);
            }

            var msg = await MessageResource.CreateAsync(createParams);

            logger.LogInformation("[Twilio] Sent to {Phone}. SID: {Sid} Status: {Status} Media: {HasMedia}",
                toPhone, msg.Sid, msg.Status, mediaUrl != null);

            return (msg.Status?.ToString() ?? "queued", msg.Sid, null);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "[Twilio] Exception sending to {Phone}", toPhone);
            return ("failed", null, ex.Message.Length > 1000 ? ex.Message[..1000] : ex.Message);
        }
    }
}

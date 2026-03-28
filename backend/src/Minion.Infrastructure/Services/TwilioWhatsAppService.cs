using System.Globalization;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Minion.Domain.Interfaces;
using Minion.Infrastructure.Helpers;
using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Twilio.Types;

namespace Minion.Infrastructure.Services;

/// <summary>
/// WhatsApp notification via Twilio API.
///
/// Dev mode (WhatsApp:Enabled=false):
///   Logs the message body to console — no Twilio account needed.
///
/// Sandbox test (WhatsApp:Enabled=true + sandbox):
///   1. Create a free Twilio account at https://twilio.com
///   2. Go to Messaging → Try it out → Send a WhatsApp message
///   3. Have the recipient send "join {keyword}" to whatsapp:+14155238886
///   4. Set WhatsApp:AccountSid, WhatsApp:AuthToken in appsettings
///   5. WhatsApp:From = "whatsapp:+14155238886" (Twilio sandbox number)
///
/// Production (approved template required):
///   1. Buy a Twilio number with WhatsApp capability
///   2. Register your WhatsApp Business Profile
///   3. Submit message templates to Meta for approval
///   4. Set WhatsApp:From = "whatsapp:+YOUR_NUMBER"
/// </summary>
public class TwilioWhatsAppService : IWhatsAppService
{
    private readonly IConfiguration _config;
    private readonly ILogger<TwilioWhatsAppService> _logger;

    public TwilioWhatsAppService(IConfiguration config, ILogger<TwilioWhatsAppService> logger)
    {
        _config = config;
        _logger = logger;
    }

    public async Task SendDelegationRequestAsync(
        string toPhone, string toName, string grantorName, string orgName,
        string operationNames, DateTime validFrom, DateTime validTo, string? notes,
        string acceptUrl, string rejectUrl, CancellationToken ct = default)
    {
        var normalizedPhone = PhoneNormalizerHelper.Normalize(toPhone);
        if (normalizedPhone == null)
        {
            _logger.LogWarning("[WHATSAPP] Skipped — invalid/missing phone number: '{Phone}'", toPhone);
            return;
        }

        var body = BuildMessage(toName, grantorName, orgName, operationNames,
            validFrom, validTo, notes, acceptUrl, rejectUrl);

        var enabled = _config["WhatsApp:Enabled"] == "true";
        if (!enabled)
        {
            _logger.LogInformation(
                "[WHATSAPP-DEV] To: {Phone}\n{Body}",
                normalizedPhone, body);
            return;
        }

        var accountSid = _config["WhatsApp:AccountSid"]
            ?? throw new InvalidOperationException("WhatsApp:AccountSid not configured");
        var authToken = _config["WhatsApp:AuthToken"]
            ?? throw new InvalidOperationException("WhatsApp:AuthToken not configured");
        var from = _config["WhatsApp:From"] ?? "whatsapp:+14155238886";

        TwilioClient.Init(accountSid, authToken);

        var message = await MessageResource.CreateAsync(
            to: new PhoneNumber($"whatsapp:{normalizedPhone}"),
            from: new PhoneNumber(from),
            body: body);

        _logger.LogInformation(
            "[WHATSAPP] Sent to {Phone}. Twilio SID: {Sid}, Status: {Status}",
            normalizedPhone, message.Sid, message.Status);
    }

    private static string BuildMessage(
        string toName, string grantorName, string orgName, string operationNames,
        DateTime validFrom, DateTime validTo, string? notes,
        string acceptUrl, string rejectUrl)
    {
        var sb = new StringBuilder();
        sb.AppendLine("⚡ *Minion – Yetki Talebi*");
        sb.AppendLine();
        sb.AppendLine($"Merhaba *{toName}*,");
        sb.AppendLine();
        sb.AppendLine($"*{grantorName}*, sizi *{orgName}* kurumunda aşağıdaki işlemleri yapmanız için yetkilendirmek istiyor:");
        sb.AppendLine();
        sb.AppendLine($"📋 *İşlemler:* {operationNames}");
        sb.AppendLine($"📅 *Geçerlilik:* {validFrom.ToString("dd.MM.yyyy HH:mm", CultureInfo.InvariantCulture)} – {validTo.ToString("dd.MM.yyyy HH:mm", CultureInfo.InvariantCulture)}");

        if (!string.IsNullOrWhiteSpace(notes))
            sb.AppendLine($"📝 *Not:* {notes}");

        sb.AppendLine();
        sb.AppendLine("*Bu talebi değerlendirmek için:*");
        sb.AppendLine($"✅ Kabul Et → {acceptUrl}");
        sb.AppendLine($"❌ Reddet  → {rejectUrl}");
        sb.AppendLine();
        sb.AppendLine("📲 *Minion uygulamasını indirin:*");
        sb.AppendLine("• App Store: https://apps.apple.com/app/minion");
        sb.AppendLine("• Google Play: https://play.google.com/store/apps/details?id=com.minion.minion_app");

        return sb.ToString().TrimEnd();
    }

}

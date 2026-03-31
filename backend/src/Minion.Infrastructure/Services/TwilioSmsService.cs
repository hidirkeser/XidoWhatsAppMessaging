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
/// SMS notification via Twilio API.
///
/// Dev mode (Sms:Enabled=false):
///   Logs the message body to console — no Twilio account needed.
///
/// Production:
///   Set Sms:AccountSid, Sms:AuthToken, Sms:From in appsettings.
///   Sms:From must be a Twilio phone number (e.g. "+46701234567").
/// </summary>
public class TwilioSmsService : ISmsService
{
    private readonly IConfiguration _config;
    private readonly ILogger<TwilioSmsService> _logger;

    public TwilioSmsService(IConfiguration config, ILogger<TwilioSmsService> logger)
    {
        _config = config;
        _logger = logger;
    }

    public async Task SendAsync(string toPhone, string message, CancellationToken ct = default)
    {
        var normalizedPhone = PhoneNormalizerHelper.Normalize(toPhone);
        if (normalizedPhone == null)
        {
            _logger.LogWarning("[SMS] Skipped — invalid/missing phone number: '{Phone}'", toPhone);
            return;
        }

        var enabled = _config["Sms:Enabled"] == "true";
        if (!enabled)
        {
            _logger.LogInformation("[SMS-DEV] To: {Phone}\n{Body}", normalizedPhone, message);
            return;
        }

        var accountSid = _config["Sms:AccountSid"]
            ?? throw new InvalidOperationException("Sms:AccountSid not configured");
        var authToken = _config["Sms:AuthToken"]
            ?? throw new InvalidOperationException("Sms:AuthToken not configured");
        var from = _config["Sms:From"]
            ?? throw new InvalidOperationException("Sms:From not configured");

        TwilioClient.Init(accountSid, authToken);

        var msg = await MessageResource.CreateAsync(
            to:   new PhoneNumber(normalizedPhone),
            from: new PhoneNumber(from),
            body: message);

        _logger.LogInformation("[SMS] Sent to {Phone}. Twilio SID: {Sid}, Status: {Status}",
            normalizedPhone, msg.Sid, msg.Status);
    }

    public async Task SendDelegationRequestAsync(
        string toPhone, string toName, string grantorName, string orgName,
        string operationNames, DateTime validFrom, DateTime validTo, string? notes,
        string acceptUrl, string rejectUrl, CancellationToken ct = default)
    {
        var normalizedPhone = PhoneNormalizerHelper.Normalize(toPhone);
        if (normalizedPhone == null)
        {
            _logger.LogWarning("[SMS] Skipped — invalid/missing phone number: '{Phone}'", toPhone);
            return;
        }

        var body = BuildMessage(toName, grantorName, orgName, operationNames,
            validFrom, validTo, notes, acceptUrl, rejectUrl);

        var enabled = _config["Sms:Enabled"] == "true";
        if (!enabled)
        {
            _logger.LogInformation("[SMS-DEV] To: {Phone}\n{Body}", normalizedPhone, body);
            return;
        }

        var accountSid = _config["Sms:AccountSid"]
            ?? throw new InvalidOperationException("Sms:AccountSid not configured");
        var authToken = _config["Sms:AuthToken"]
            ?? throw new InvalidOperationException("Sms:AuthToken not configured");
        var from = _config["Sms:From"]
            ?? throw new InvalidOperationException("Sms:From not configured");

        TwilioClient.Init(accountSid, authToken);

        var message = await MessageResource.CreateAsync(
            to:   new PhoneNumber(normalizedPhone),
            from: new PhoneNumber(from),
            body: body);

        _logger.LogInformation(
            "[SMS] Sent to {Phone}. Twilio SID: {Sid}, Status: {Status}",
            normalizedPhone, message.Sid, message.Status);
    }

    private static string BuildMessage(
        string toName, string grantorName, string orgName, string operationNames,
        DateTime validFrom, DateTime validTo, string? notes,
        string acceptUrl, string rejectUrl)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"Merhaba {toName},");
        sb.AppendLine();
        sb.AppendLine($"{grantorName}, sizi {orgName} kurumunda yetkilendirmek istiyor.");
        sb.AppendLine($"İşlemler: {operationNames}");
        sb.AppendLine($"Geçerlilik: {validFrom.ToString("dd.MM.yyyy HH:mm", CultureInfo.InvariantCulture)} - {validTo.ToString("dd.MM.yyyy HH:mm", CultureInfo.InvariantCulture)}");

        if (!string.IsNullOrWhiteSpace(notes))
            sb.AppendLine($"Not: {notes}");

        sb.AppendLine();
        sb.AppendLine($"Kabul Et: {acceptUrl}");
        sb.AppendLine($"Reddet: {rejectUrl}");

        return sb.ToString().TrimEnd();
    }
}

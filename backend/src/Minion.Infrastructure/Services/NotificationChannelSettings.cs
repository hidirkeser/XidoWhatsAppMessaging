using Microsoft.Extensions.Configuration;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services;

/// <summary>
/// Reads appsettings to determine which notification channels are configured
/// and available on the current deployment.
/// </summary>
public class NotificationChannelSettings : INotificationChannelSettings
{
    public bool InAppAvailable    { get; }
    public bool PushAvailable     { get; }
    public bool EmailAvailable    { get; }
    public bool WhatsAppAvailable { get; }
    public bool SmsAvailable      { get; }

    public NotificationChannelSettings(IConfiguration cfg)
    {
        InAppAvailable = true;

        PushAvailable = IsTrue(cfg["Firebase:Enabled"])
                        && (!string.IsNullOrWhiteSpace(cfg["Firebase:ServiceAccountJson"])
                            || !string.IsNullOrWhiteSpace(cfg["Firebase:ServiceAccountPath"]));

        EmailAvailable = IsTrue(cfg["Email:Enabled"])
                         && !string.IsNullOrWhiteSpace(cfg["Email:SmtpHost"]);

        WhatsAppAvailable = IsTrue(cfg["WhatsApp:Enabled"])
                            && !string.IsNullOrWhiteSpace(cfg["WhatsApp:AccountSid"])
                            && !string.IsNullOrWhiteSpace(cfg["WhatsApp:AuthToken"]);

        SmsAvailable = IsTrue(cfg["Sms:Enabled"])
                       && !string.IsNullOrWhiteSpace(cfg["Sms:AccountSid"])
                       && !string.IsNullOrWhiteSpace(cfg["Sms:AuthToken"]);
    }

    private static bool IsTrue(string? value) =>
        string.Equals(value, "true", StringComparison.OrdinalIgnoreCase);
}

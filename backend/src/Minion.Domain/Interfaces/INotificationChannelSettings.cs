namespace Minion.Domain.Interfaces;

/// <summary>
/// Provides information about which notification channels are configured
/// and available on this deployment. Implemented by Infrastructure reading appsettings.
/// </summary>
public interface INotificationChannelSettings
{
    bool InAppAvailable    { get; }
    bool PushAvailable     { get; }
    bool EmailAvailable    { get; }
    bool WhatsAppAvailable { get; }
    bool SmsAvailable      { get; }
}

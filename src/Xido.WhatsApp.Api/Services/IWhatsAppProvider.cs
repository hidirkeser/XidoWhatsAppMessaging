namespace Xido.WhatsApp.Api.Services;

public interface IWhatsAppProvider
{
    string ProviderName { get; }

    /// <param name="mediaUrl">Optional public URL for MMS image/video. Only Twilio supports this.</param>
    Task<(string status, string? externalId, string? error)> SendAsync(
        string toPhone, string? recipientName, string body,
        string? mediaUrl = null, CancellationToken ct = default);
}

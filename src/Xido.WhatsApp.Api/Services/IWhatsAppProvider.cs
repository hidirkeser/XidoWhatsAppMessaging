using Xido.WhatsApp.Api.Models;

namespace Xido.WhatsApp.Api.Services;

public interface IWhatsAppProvider
{
    string ProviderName { get; }

    Task<(string status, string? externalId, string? error)> SendAsync(
        string toPhone, string? recipientName, string body, CancellationToken ct = default);
}

namespace Minion.Domain.Interfaces;

public interface IFcmService
{
    Task SendAsync(
        IEnumerable<string> deviceTokens,
        string title,
        string body,
        string notificationType,
        Guid? referenceId = null,
        CancellationToken ct = default);
}

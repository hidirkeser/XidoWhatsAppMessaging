using Minion.Domain.Enums;

namespace Minion.Domain.Interfaces;

public interface INotificationService
{
    Task SendAsync(Guid userId, string title, string body, NotificationType type, Guid? referenceId = null, CancellationToken ct = default);
    Task SendPushAsync(Guid userId, string title, string body, CancellationToken ct = default);
}

namespace Minion.Domain.Interfaces;

public interface INotificationHubService
{
    Task SendToUserAsync(Guid userId, string method, object data, CancellationToken ct = default);
}

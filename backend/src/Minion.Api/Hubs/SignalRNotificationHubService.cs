using Microsoft.AspNetCore.SignalR;
using Minion.Domain.Interfaces;

namespace Minion.Api.Hubs;

public class SignalRNotificationHubService : INotificationHubService
{
    private readonly IHubContext<NotificationHub> _hubContext;

    public SignalRNotificationHubService(IHubContext<NotificationHub> hubContext)
    {
        _hubContext = hubContext;
    }

    public async Task SendToUserAsync(Guid userId, string method, object data, CancellationToken ct = default)
    {
        await _hubContext.Clients.Group($"user_{userId}").SendAsync(method, data, ct);
    }
}

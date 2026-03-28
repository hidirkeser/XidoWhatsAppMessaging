using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services;

public class NotificationService : INotificationService
{
    private readonly IApplicationDbContext _context;
    private readonly INotificationHubService _hubService;
    private readonly ILogger<NotificationService> _logger;

    public NotificationService(
        IApplicationDbContext context,
        INotificationHubService hubService,
        ILogger<NotificationService> logger)
    {
        _context = context;
        _hubService = hubService;
        _logger = logger;
    }

    public async Task SendAsync(Guid userId, string title, string body, NotificationType type,
        Guid? referenceId = null, CancellationToken ct = default)
    {
        var notification = new Notification
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Title = title,
            Body = body,
            Type = type,
            ReferenceId = referenceId
        };

        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync(ct);

        // Real-time via SignalR
        await _hubService.SendToUserAsync(userId, "ReceiveNotification", new
        {
            notification.Id,
            notification.Title,
            notification.Body,
            Type = type.ToString(),
            notification.ReferenceId,
            notification.CreatedAt
        }, ct);

        _logger.LogInformation("Notification sent to {UserId}: {Title}", userId, title);

        await SendPushAsync(userId, title, body, ct);
    }

    public async Task SendPushAsync(Guid userId, string title, string body, CancellationToken ct = default)
    {
        var tokens = await _context.DeviceTokens
            .Where(d => d.UserId == userId && d.IsActive)
            .Select(d => new { d.Token, d.Platform })
            .ToListAsync(ct);

        if (tokens.Count == 0) return;

        // TODO: Implement actual FCM/APNs push via Azure Notification Hubs
        foreach (var token in tokens)
        {
            _logger.LogInformation("Push to {Platform} device for user {UserId}: {Title}",
                token.Platform, userId, title);
        }
    }
}

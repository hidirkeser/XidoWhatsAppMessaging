using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services;

public class NotificationService : INotificationService
{
    private readonly IApplicationDbContext _context;
    private readonly INotificationHubService _hubService;
    private readonly IEmailService _emailService;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IConfiguration _configuration;
    private readonly ILogger<NotificationService> _logger;

    public NotificationService(
        IApplicationDbContext context,
        INotificationHubService hubService,
        IEmailService emailService,
        IJwtTokenService jwtTokenService,
        IConfiguration configuration,
        ILogger<NotificationService> logger)
    {
        _context = context;
        _hubService = hubService;
        _emailService = emailService;
        _jwtTokenService = jwtTokenService;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task SendAsync(Guid userId, string title, string body, NotificationType type,
        Guid? referenceId = null, CancellationToken ct = default)
    {
        // 1. Persist in-app notification
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

        // 2. Real-time via SignalR
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

        // 3. Push notification (FCM/APNs)
        await SendPushAsync(userId, title, body, ct);

        // 4. Email — only for DelegationGranted (the delegate must approve/reject)
        if (type == NotificationType.DelegationGranted && referenceId.HasValue)
        {
            await TrySendDelegationEmailAsync(referenceId.Value, ct);
        }
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

    // ── Email helper ───────────────────────────────────────────────────────────

    private async Task TrySendDelegationEmailAsync(Guid delegationId, CancellationToken ct)
    {
        try
        {
            var delegation = await _context.Delegations
                .Include(d => d.GrantorUser)
                .Include(d => d.DelegateUser)
                .Include(d => d.Organization)
                .Include(d => d.DelegationOperations)
                    .ThenInclude(op => op.OperationType)
                .FirstOrDefaultAsync(d => d.Id == delegationId, ct);

            if (delegation?.DelegateUser?.Email is not { Length: > 0 } delegateEmail)
            {
                _logger.LogInformation(
                    "[EMAIL] Skipped delegation email — delegate has no email. DelegationId: {Id}", delegationId);
                return;
            }

            var acceptToken = _jwtTokenService.GenerateDelegationActionToken(
                delegation.Id, delegation.DelegateUserId, "accept");
            var rejectToken = _jwtTokenService.GenerateDelegationActionToken(
                delegation.Id, delegation.DelegateUserId, "reject");

            var baseUrl = _configuration["AppBaseUrl"]?.TrimEnd('/') ?? "http://localhost:5131";
            var acceptUrl = $"{baseUrl}/api/delegations/email-action?token={acceptToken}";
            var rejectUrl = $"{baseUrl}/api/delegations/email-action?token={rejectToken}";

            var operationNames = string.Join(", ",
                delegation.DelegationOperations.Select(op => op.OperationType.Name));

            await _emailService.SendDelegationRequestAsync(
                toEmail: delegateEmail,
                toName: delegation.DelegateUser.FullName,
                grantorName: delegation.GrantorUser.FullName,
                orgName: delegation.Organization.Name,
                operationNames: operationNames,
                validFrom: delegation.ValidFrom,
                validTo: delegation.ValidTo,
                notes: delegation.Notes,
                acceptUrl: acceptUrl,
                rejectUrl: rejectUrl,
                ct: ct);
        }
        catch (Exception ex)
        {
            // Never let email failure break the main flow
            _logger.LogError(ex, "[EMAIL] Failed to send delegation email for DelegationId: {Id}", delegationId);
        }
    }
}

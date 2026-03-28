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
    private readonly IWhatsAppService _whatsAppService;
    private readonly IFcmService _fcmService;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IConfiguration _configuration;
    private readonly ILogger<NotificationService> _logger;

    public NotificationService(
        IApplicationDbContext context,
        INotificationHubService hubService,
        IEmailService emailService,
        IWhatsAppService whatsAppService,
        IFcmService fcmService,
        IJwtTokenService jwtTokenService,
        IConfiguration configuration,
        ILogger<NotificationService> logger)
    {
        _context = context;
        _hubService = hubService;
        _emailService = emailService;
        _whatsAppService = whatsAppService;
        _fcmService = fcmService;
        _jwtTokenService = jwtTokenService;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task SendAsync(
        Guid userId, string title, string body,
        NotificationType type, Guid? referenceId = null, CancellationToken ct = default)
    {
        // ── 1. Persist in-app notification ──────────────────────────────────
        var notification = new Notification
        {
            Id          = Guid.NewGuid(),
            UserId      = userId,
            Title       = title,
            Body        = body,
            Type        = type,
            ReferenceId = referenceId,
        };
        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync(ct);

        // ── 2. SignalR real-time ─────────────────────────────────────────────
        await _hubService.SendToUserAsync(userId, "ReceiveNotification", new
        {
            notification.Id,
            notification.Title,
            notification.Body,
            Type        = type.ToString(),
            notification.ReferenceId,
            notification.CreatedAt,
        }, ct);

        _logger.LogInformation("Notification sent to {UserId}: [{Type}] {Title}", userId, type, title);

        // ── 3. FCM push (all notification types) ────────────────────────────
        await SendPushAsync(userId, title, body, type.ToString(), referenceId, ct);

        // ── 4. Email + WhatsApp (only for new delegation requests) ──────────
        if (type == NotificationType.DelegationGranted && referenceId.HasValue)
            await TrySendDelegationExternalNotificationsAsync(referenceId.Value, ct);
    }

    // ── Push via FCM ─────────────────────────────────────────────────────────

    public async Task SendPushAsync(
        Guid userId, string title, string body, CancellationToken ct = default)
        => await SendPushAsync(userId, title, body, "General", null, ct);

    private async Task SendPushAsync(
        Guid userId, string title, string body,
        string notificationType, Guid? referenceId, CancellationToken ct)
    {
        var tokens = await _context.DeviceTokens
            .Where(d => d.UserId == userId && d.IsActive)
            .Select(d => d.Token)
            .ToListAsync(ct);

        if (tokens.Count == 0)
        {
            _logger.LogDebug("[FCM] No device tokens for user {UserId}", userId);
            return;
        }

        await _fcmService.SendAsync(tokens, title, body, notificationType, referenceId, ct);
    }

    // ── Email + WhatsApp helper for delegation requests ───────────────────────

    private async Task TrySendDelegationExternalNotificationsAsync(
        Guid delegationId, CancellationToken ct)
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

            if (delegation == null) return;

            var baseUrl = _configuration["AppBaseUrl"]?.TrimEnd('/') ?? "http://localhost:5131";
            var operationNames = string.Join(", ",
                delegation.DelegationOperations.Select(op => op.OperationType.Name));

            var acceptToken = _jwtTokenService.GenerateDelegationActionToken(
                delegation.Id, delegation.DelegateUserId, "accept");
            var rejectToken = _jwtTokenService.GenerateDelegationActionToken(
                delegation.Id, delegation.DelegateUserId, "reject");

            var acceptUrl = $"{baseUrl}/api/delegations/email-action?token={acceptToken}";
            var rejectUrl = $"{baseUrl}/api/delegations/email-action?token={rejectToken}";

            // ── Email ──
            if (!string.IsNullOrWhiteSpace(delegation.DelegateUser.Email))
            {
                await _emailService.SendDelegationRequestAsync(
                    toEmail       : delegation.DelegateUser.Email,
                    toName        : delegation.DelegateUser.FullName,
                    grantorName   : delegation.GrantorUser.FullName,
                    orgName       : delegation.Organization.Name,
                    operationNames: operationNames,
                    validFrom     : delegation.ValidFrom,
                    validTo       : delegation.ValidTo,
                    notes         : delegation.Notes,
                    acceptUrl     : acceptUrl,
                    rejectUrl     : rejectUrl,
                    ct            : ct);
            }
            else
            {
                _logger.LogInformation(
                    "[EMAIL] Skipped — delegate has no email. DelegationId: {Id}", delegationId);
            }

            // ── WhatsApp ──
            if (!string.IsNullOrWhiteSpace(delegation.DelegateUser.Phone))
            {
                await _whatsAppService.SendDelegationRequestAsync(
                    toPhone       : delegation.DelegateUser.Phone,
                    toName        : delegation.DelegateUser.FullName,
                    grantorName   : delegation.GrantorUser.FullName,
                    orgName       : delegation.Organization.Name,
                    operationNames: operationNames,
                    validFrom     : delegation.ValidFrom,
                    validTo       : delegation.ValidTo,
                    notes         : delegation.Notes,
                    acceptUrl     : acceptUrl,
                    rejectUrl     : rejectUrl,
                    ct            : ct);
            }
            else
            {
                _logger.LogInformation(
                    "[WHATSAPP] Skipped — delegate has no phone number. DelegationId: {Id}", delegationId);
            }
        }
        catch (Exception ex)
        {
            // Never let external notification failure break the main flow
            _logger.LogError(ex,
                "[NOTIFY] External notification failed for DelegationId: {Id}", delegationId);
        }
    }
}

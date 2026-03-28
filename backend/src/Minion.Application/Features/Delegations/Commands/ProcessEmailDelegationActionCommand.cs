using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Delegations.Commands;

/// <summary>
/// Handles delegation accept/reject coming from a tokenized email link.
/// Does NOT require the user to be authenticated — the JWT token IS the auth.
/// </summary>
public record ProcessEmailDelegationActionCommand(
    Guid DelegationId,
    Guid DelegateUserId,
    string Action   // "accept" or "reject"
) : IRequest<(bool Success, string Title, string Message)>;

public class ProcessEmailDelegationActionCommandHandler
    : IRequestHandler<ProcessEmailDelegationActionCommand, (bool Success, string Title, string Message)>
{
    private readonly IApplicationDbContext _context;
    private readonly ICreditService _creditService;
    private readonly IAuditLogService _audit;
    private readonly INotificationService _notification;

    public ProcessEmailDelegationActionCommandHandler(
        IApplicationDbContext context,
        ICreditService creditService,
        IAuditLogService audit,
        INotificationService notification)
    {
        _context = context;
        _creditService = creditService;
        _audit = audit;
        _notification = notification;
    }

    public async Task<(bool Success, string Title, string Message)> Handle(
        ProcessEmailDelegationActionCommand request, CancellationToken ct)
    {
        var delegation = await _context.Delegations
            .Include(d => d.GrantorUser)
            .Include(d => d.DelegateUser)
            .Include(d => d.Organization)
            .FirstOrDefaultAsync(d => d.Id == request.DelegationId, ct);

        if (delegation == null)
            return (false, "Talep Bulunamadı", "Yetkilendirme talebi bulunamadı veya silinmiş olabilir.");

        // Security: verify the token's delegateUserId matches the delegation
        if (delegation.DelegateUserId != request.DelegateUserId)
            return (false, "Yetkisiz Erişim", "Bu işlemi gerçekleştirme yetkiniz yok.");

        if (delegation.Status != DelegationStatus.PendingApproval)
        {
            var statusLabel = delegation.Status switch
            {
                DelegationStatus.Active    => "zaten kabul edildi",
                DelegationStatus.Rejected  => "zaten reddedildi",
                DelegationStatus.Revoked   => "iptal edildi",
                DelegationStatus.Expired   => "süresi doldu",
                _ => $"'{delegation.Status}' durumunda"
            };
            return (false, "İşlem Yapılamadı",
                $"Bu talep {statusLabel}. Yeniden işlem yapılamaz.");
        }

        if (request.Action == "accept")
        {
            delegation.Status = DelegationStatus.Active;
            delegation.AcceptedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync(ct);

            await _audit.LogAsync(AuditAction.Accept,
                request.DelegateUserId, delegation.DelegateUser.FullName,
                targetUserId: delegation.GrantorUserId,
                organizationId: delegation.OrganizationId,
                delegationId: delegation.Id, ct: ct);

            await _notification.SendAsync(delegation.GrantorUserId,
                "Yetki kabul edildi",
                $"{delegation.DelegateUser.FullName}, {delegation.Organization.Name} kurumu için verdiğiniz yetkiyi kabul etti.",
                NotificationType.DelegationAccepted, delegation.Id, ct);

            return (true,
                "✓ Yetki Kabul Edildi",
                $"{delegation.GrantorUser.FullName} tarafından verilen {delegation.Organization.Name} yetkisini başarıyla kabul ettiniz.");
        }
        else // reject
        {
            delegation.Status = DelegationStatus.Rejected;
            delegation.RejectedAt = DateTime.UtcNow;

            // Refund credits to grantor
            await _creditService.RefundAsync(
                delegation.GrantorUserId, delegation.CreditsDeducted,
                delegation.Id, request.DelegateUserId, ct);

            await _context.SaveChangesAsync(ct);

            await _audit.LogAsync(AuditAction.Reject,
                request.DelegateUserId, delegation.DelegateUser.FullName,
                targetUserId: delegation.GrantorUserId,
                organizationId: delegation.OrganizationId,
                delegationId: delegation.Id, ct: ct);

            await _notification.SendAsync(delegation.GrantorUserId,
                "Yetki reddedildi",
                $"{delegation.DelegateUser.FullName}, {delegation.Organization.Name} kurumu için verdiğiniz yetkiyi reddetti.",
                NotificationType.DelegationRejected, delegation.Id, ct);

            return (true,
                "✗ Yetki Reddedildi",
                $"{delegation.GrantorUser.FullName} tarafından verilen {delegation.Organization.Name} yetkisini reddettiniz. Kontor iadesi yapıldı.");
        }
    }
}

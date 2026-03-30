using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Delegations.Commands;

public record RejectDelegationCommand(Guid DelegationId, string? RejectionNote = null) : IRequest<Unit>;

public class RejectDelegationCommandHandler : IRequestHandler<RejectDelegationCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly ICreditService _creditService;
    private readonly IAuditLogService _audit;
    private readonly INotificationService _notification;

    public RejectDelegationCommandHandler(
        IApplicationDbContext context, ICurrentUserService currentUser,
        ICreditService creditService, IAuditLogService audit, INotificationService notification)
    {
        _context = context;
        _currentUser = currentUser;
        _creditService = creditService;
        _audit = audit;
        _notification = notification;
    }

    public async Task<Unit> Handle(RejectDelegationCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var delegation = await _context.Delegations
            .Include(d => d.GrantorUser)
            .Include(d => d.DelegateUser)
            .Include(d => d.Organization)
            .FirstOrDefaultAsync(d => d.Id == request.DelegationId, ct)
            ?? throw new NotFoundException("Delegation", request.DelegationId);

        if (delegation.DelegateUserId != userId)
            throw new ForbiddenException("Only the delegate can reject this delegation.", "ONLY_DELEGATE_CAN_REJECT");

        if (delegation.Status != DelegationStatus.PendingApproval)
            throw new DomainException($"Delegation cannot be rejected in status '{delegation.Status}'.", "DELEGATION_INVALID_STATUS");

        delegation.Status = DelegationStatus.Rejected;
        delegation.RejectedAt = DateTime.UtcNow;
        delegation.RejectionNote = request.RejectionNote;

        // Refund credits to grantor
        await _creditService.RefundAsync(delegation.GrantorUserId, delegation.CreditsDeducted,
            delegation.Id, userId, ct);

        await _context.SaveChangesAsync(ct);

        await _audit.LogAsync(AuditAction.Reject, userId, delegation.DelegateUser.FullName,
            targetUserId: delegation.GrantorUserId, organizationId: delegation.OrganizationId,
            delegationId: delegation.Id, ct: ct);

        await _notification.SendAsync(delegation.GrantorUserId,
            "Yetki reddedildi",
            $"{delegation.DelegateUser.FullName} {delegation.Organization.Name} kurumu için verdiğiniz yetkiyi reddetti.",
            NotificationType.DelegationRejected, delegation.Id, ct);

        return Unit.Value;
    }
}

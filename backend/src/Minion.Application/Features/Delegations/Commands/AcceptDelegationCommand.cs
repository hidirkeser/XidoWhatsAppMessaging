using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Delegations.Commands;

public record AcceptDelegationCommand(
    Guid DelegationId,
    string? DelegateSignOrderRef = null,
    string? DelegateSignature = null) : IRequest<Unit>;

public class AcceptDelegationCommandHandler : IRequestHandler<AcceptDelegationCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly IAuditLogService _audit;
    private readonly INotificationService _notification;

    public AcceptDelegationCommandHandler(
        IApplicationDbContext context, ICurrentUserService currentUser,
        IAuditLogService audit, INotificationService notification)
    {
        _context = context;
        _currentUser = currentUser;
        _audit = audit;
        _notification = notification;
    }

    public async Task<Unit> Handle(AcceptDelegationCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var delegation = await _context.Delegations
            .Include(d => d.GrantorUser)
            .Include(d => d.DelegateUser)
            .Include(d => d.Organization)
            .FirstOrDefaultAsync(d => d.Id == request.DelegationId, ct)
            ?? throw new NotFoundException("Delegation", request.DelegationId);

        if (delegation.DelegateUserId != userId)
            throw new ForbiddenException("Only the delegate can accept this delegation.", "ONLY_DELEGATE_CAN_ACCEPT");

        if (delegation.Status != DelegationStatus.PendingApproval)
            throw new DomainException($"Delegation cannot be accepted in status '{delegation.Status}'.", "DELEGATION_INVALID_STATUS");

        delegation.Status = DelegationStatus.Active;
        delegation.AcceptedAt = DateTime.UtcNow;
        delegation.DelegateSignOrderRef = request.DelegateSignOrderRef;
        delegation.DelegateSignature = request.DelegateSignature;
        await _context.SaveChangesAsync(ct);

        await _audit.LogAsync(AuditAction.Accept, userId, delegation.DelegateUser.FullName,
            targetUserId: delegation.GrantorUserId, organizationId: delegation.OrganizationId,
            delegationId: delegation.Id, ct: ct);

        await _notification.SendAsync(delegation.GrantorUserId,
            "Yetki kabul edildi",
            $"{delegation.DelegateUser.FullName} {delegation.Organization.Name} kurumu için verdiğiniz yetkiyi kabul etti.",
            NotificationType.DelegationAccepted, delegation.Id, ct);

        return Unit.Value;
    }
}

using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Delegations.Commands;

public record RevokeDelegationCommand(Guid DelegationId) : IRequest<Unit>;

public class RevokeDelegationCommandHandler : IRequestHandler<RevokeDelegationCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly IAuditLogService _audit;
    private readonly INotificationService _notification;

    public RevokeDelegationCommandHandler(
        IApplicationDbContext context, ICurrentUserService currentUser,
        IAuditLogService audit, INotificationService notification)
    {
        _context = context;
        _currentUser = currentUser;
        _audit = audit;
        _notification = notification;
    }

    public async Task<Unit> Handle(RevokeDelegationCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var delegation = await _context.Delegations
            .Include(d => d.GrantorUser)
            .Include(d => d.DelegateUser)
            .Include(d => d.Organization)
            .FirstOrDefaultAsync(d => d.Id == request.DelegationId, ct)
            ?? throw new NotFoundException("Delegation", request.DelegationId);

        if (delegation.GrantorUserId != userId)
            throw new ForbiddenException("Only the grantor can revoke this delegation.");

        if (delegation.Status != DelegationStatus.Active && delegation.Status != DelegationStatus.PendingApproval)
            throw new DomainException($"Delegation cannot be revoked in status '{delegation.Status}'.");

        delegation.Status = DelegationStatus.Revoked;
        delegation.RevokedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(ct);

        await _audit.LogAsync(AuditAction.Revoke, userId, delegation.GrantorUser.FullName,
            targetUserId: delegation.DelegateUserId, organizationId: delegation.OrganizationId,
            delegationId: delegation.Id, ct: ct);

        await _notification.SendAsync(delegation.DelegateUserId,
            "Yetki iptal edildi",
            $"{delegation.GrantorUser.FullName} {delegation.Organization.Name} kurumu için verdiği yetkiyi iptal etti.",
            NotificationType.DelegationRevoked, delegation.Id, ct);

        return Unit.Value;
    }
}

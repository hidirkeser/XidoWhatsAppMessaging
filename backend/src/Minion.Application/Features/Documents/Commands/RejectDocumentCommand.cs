using MediatR;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Minion.Application.Features.Documents.Commands;

public record RejectDocumentCommand(
    Guid DelegationId,
    string? Reason,
    string? IpAddress) : IRequest<Unit>;

public class RejectDocumentCommandHandler : IRequestHandler<RejectDocumentCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly IDocumentService _documentService;
    private readonly ICurrentUserService _currentUser;
    private readonly INotificationService _notification;

    public RejectDocumentCommandHandler(
        IApplicationDbContext context,
        IDocumentService documentService,
        ICurrentUserService currentUser,
        INotificationService notification)
    {
        _context = context;
        _documentService = documentService;
        _currentUser = currentUser;
        _notification = notification;
    }

    public async Task<Unit> Handle(RejectDocumentCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var doc = await _context.DelegationDocuments
            .Include(d => d.Delegation).ThenInclude(del => del.GrantorUser)
            .Include(d => d.Delegation).ThenInclude(del => del.DelegateUser)
            .FirstOrDefaultAsync(d => d.DelegationId == request.DelegationId, ct)
            ?? throw new NotFoundException("DelegationDocument", request.DelegationId);

        var delegation = doc.Delegation;
        if (userId != delegation.GrantorUserId && userId != delegation.DelegateUserId)
            throw new DomainException("Only the grantor or delegate can reject this document.", "NOT_AUTHORIZED");

        var userName = userId == delegation.GrantorUserId
            ? delegation.GrantorUser.FullName
            : delegation.DelegateUser.FullName;

        await _documentService.RejectDocumentAsync(doc.Id, userId, userName, request.Reason, request.IpAddress, ct);

        // Notify the other party
        var notifyUserId = userId == delegation.GrantorUserId
            ? delegation.DelegateUserId
            : delegation.GrantorUserId;

        await _notification.SendAsync(notifyUserId,
            "Dokuman reddedildi",
            $"{userName} dokumani reddetti." + (request.Reason != null ? $" Sebep: {request.Reason}" : ""),
            Domain.Enums.NotificationType.DelegationRejected, delegation.Id, ct);

        return Unit.Value;
    }
}

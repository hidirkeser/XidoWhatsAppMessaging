using MediatR;
using Minion.Domain.Entities;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Minion.Application.Features.Documents.Commands;

public record ApproveDocumentCommand(
    Guid DelegationId,
    string BankIdSignature,
    string? IpAddress) : IRequest<Unit>;

public class ApproveDocumentCommandHandler : IRequestHandler<ApproveDocumentCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly IDocumentService _documentService;
    private readonly ICurrentUserService _currentUser;
    private readonly INotificationService _notification;

    public ApproveDocumentCommandHandler(
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

    public async Task<Unit> Handle(ApproveDocumentCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var doc = await _context.DelegationDocuments
            .Include(d => d.Delegation)
            .FirstOrDefaultAsync(d => d.DelegationId == request.DelegationId, ct)
            ?? throw new NotFoundException("DelegationDocument", request.DelegationId);

        var delegation = doc.Delegation;

        if (userId == delegation.GrantorUserId)
        {
            await _documentService.ApproveByGrantorAsync(doc.Id, request.BankIdSignature, request.IpAddress, ct);

            // Notify delegate
            await _notification.SendAsync(delegation.DelegateUserId,
                "Dokuman onaylandi",
                "Yetki veren kisi dokumani onayladi. Sizin onayiniz bekleniyor.",
                Domain.Enums.NotificationType.DelegationGranted, delegation.Id, ct);
        }
        else if (userId == delegation.DelegateUserId)
        {
            await _documentService.ApproveByDelegateAsync(doc.Id, request.BankIdSignature, request.IpAddress, ct);

            // Notify grantor
            await _notification.SendAsync(delegation.GrantorUserId,
                "Dokuman onaylandi",
                "Yetkili kisi dokumani onayladi.",
                Domain.Enums.NotificationType.DelegationAccepted, delegation.Id, ct);
        }
        else
        {
            throw new DomainException("Only the grantor or delegate can approve this document.", "NOT_AUTHORIZED");
        }

        return Unit.Value;
    }
}

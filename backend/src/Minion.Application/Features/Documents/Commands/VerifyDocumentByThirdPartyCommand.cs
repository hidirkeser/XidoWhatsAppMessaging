using MediatR;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Minion.Application.Features.Documents.Commands;

public record VerifyDocumentByThirdPartyCommand(
    string VerificationCode,
    string VerifierName,
    string VerifierPersonalNumber,
    string? IpAddress) : IRequest<Unit>;

public class VerifyDocumentByThirdPartyCommandHandler : IRequestHandler<VerifyDocumentByThirdPartyCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly IDocumentService _documentService;
    private readonly INotificationService _notification;

    public VerifyDocumentByThirdPartyCommandHandler(
        IApplicationDbContext context,
        IDocumentService documentService,
        INotificationService notification)
    {
        _context = context;
        _documentService = documentService;
        _notification = notification;
    }

    public async Task<Unit> Handle(VerifyDocumentByThirdPartyCommand request, CancellationToken ct)
    {
        var doc = await _documentService.GetByVerificationCodeAsync(request.VerificationCode, ct)
            ?? throw new NotFoundException("DelegationDocument", request.VerificationCode);

        // Log 3rd party verification
        await _documentService.LogThirdPartyVerificationAsync(
            doc.Id, request.VerifierName, request.VerifierPersonalNumber, request.IpAddress, ct);

        var delegation = doc.Delegation;

        // Notify grantor
        await _notification.SendAsync(delegation.GrantorUserId,
            "Dokuman dogrulandi",
            $"{request.VerifierName} yetki belgenizi dogruladi.",
            Domain.Enums.NotificationType.DelegationGranted, delegation.Id, ct);

        // Notify delegate
        await _notification.SendAsync(delegation.DelegateUserId,
            "Dokuman dogrulandi",
            $"{request.VerifierName} yetki belgenizi dogruladi.",
            Domain.Enums.NotificationType.DelegationGranted, delegation.Id, ct);

        return Unit.Value;
    }
}

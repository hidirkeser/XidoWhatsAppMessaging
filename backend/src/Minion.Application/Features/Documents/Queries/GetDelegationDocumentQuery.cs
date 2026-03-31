using MediatR;
using Minion.Application.Features.Documents.DTOs;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Documents.Queries;

public record GetDelegationDocumentQuery(Guid DelegationId) : IRequest<DelegationDocumentDto>;

public class GetDelegationDocumentQueryHandler : IRequestHandler<GetDelegationDocumentQuery, DelegationDocumentDto>
{
    private readonly IDocumentService _documentService;
    private readonly ICurrentUserService _currentUser;

    public GetDelegationDocumentQueryHandler(IDocumentService documentService, ICurrentUserService currentUser)
    {
        _documentService = documentService;
        _currentUser = currentUser;
    }

    public async Task<DelegationDocumentDto> Handle(GetDelegationDocumentQuery request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var doc = await _documentService.GetByDelegationIdAsync(request.DelegationId, ct)
            ?? throw new NotFoundException("DelegationDocument", request.DelegationId);

        // Log view
        var viewerName = doc.Delegation.GrantorUserId == userId
            ? doc.Delegation.GrantorUser.FullName
            : doc.Delegation.DelegateUser.FullName;

        await _documentService.LogViewAsync(doc.Id, userId, viewerName, null, ct);

        return new DelegationDocumentDto(
            doc.Id, doc.DelegationId, doc.Language,
            doc.RenderedContent, doc.DocumentVersion,
            doc.Status.ToString(),
            doc.GrantorApprovedAt, doc.GrantorSignature != null,
            doc.DelegateApprovedAt, doc.DelegateSignature != null,
            doc.QrCodeData,
            doc.Delegation.GrantorUser.FullName,
            doc.Delegation.DelegateUser.FullName,
            doc.Delegation.Organization.Name,
            doc.Delegation.VerificationCode,
            doc.CreatedAt, doc.UpdatedAt);
    }
}

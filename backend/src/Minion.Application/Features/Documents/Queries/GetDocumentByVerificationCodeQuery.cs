using MediatR;
using Minion.Application.Features.Documents.DTOs;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Documents.Queries;

/// <summary>Public query — no auth required. Used after QR scan.</summary>
public record GetDocumentByVerificationCodeQuery(string VerificationCode, string? IpAddress) : IRequest<DelegationDocumentDto>;

public class GetDocumentByVerificationCodeQueryHandler : IRequestHandler<GetDocumentByVerificationCodeQuery, DelegationDocumentDto>
{
    private readonly IDocumentService _documentService;

    public GetDocumentByVerificationCodeQueryHandler(IDocumentService documentService)
        => _documentService = documentService;

    public async Task<DelegationDocumentDto> Handle(GetDocumentByVerificationCodeQuery request, CancellationToken ct)
    {
        var doc = await _documentService.GetByVerificationCodeAsync(request.VerificationCode, ct)
            ?? throw new NotFoundException("DelegationDocument", request.VerificationCode);

        // Log anonymous view
        await _documentService.LogViewAsync(doc.Id, null, "Anonymous (QR)", request.IpAddress, ct);

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

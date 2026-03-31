using MediatR;
using Minion.Application.Features.Documents.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Documents.Commands;

public record GenerateDelegationDocumentCommand(Guid DelegationId, string Language = "tr") : IRequest<DelegationDocumentDto>;

public class GenerateDelegationDocumentCommandHandler : IRequestHandler<GenerateDelegationDocumentCommand, DelegationDocumentDto>
{
    private readonly IDocumentService _documentService;

    public GenerateDelegationDocumentCommandHandler(IDocumentService documentService)
        => _documentService = documentService;

    public async Task<DelegationDocumentDto> Handle(GenerateDelegationDocumentCommand request, CancellationToken ct)
    {
        var doc = await _documentService.GenerateDocumentAsync(request.DelegationId, request.Language, ct);
        return MapToDto(doc);
    }

    private static DelegationDocumentDto MapToDto(Domain.Entities.DelegationDocument doc)
    {
        return new DelegationDocumentDto(
            doc.Id, doc.DelegationId, doc.Language,
            doc.RenderedContent, doc.DocumentVersion,
            doc.Status.ToString(),
            doc.GrantorApprovedAt, doc.GrantorSignature != null,
            doc.DelegateApprovedAt, doc.DelegateSignature != null,
            doc.QrCodeData,
            doc.Delegation?.GrantorUser?.FullName ?? "",
            doc.Delegation?.DelegateUser?.FullName ?? "",
            doc.Delegation?.Organization?.Name ?? "",
            doc.Delegation?.VerificationCode ?? "",
            doc.CreatedAt, doc.UpdatedAt);
    }
}

using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Documents.DTOs;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Documents.Queries;

public record GetDocumentTemplateByIdQuery(Guid Id) : IRequest<DocumentTemplateDto>;

public class GetDocumentTemplateByIdQueryHandler : IRequestHandler<GetDocumentTemplateByIdQuery, DocumentTemplateDto>
{
    private readonly IApplicationDbContext _context;

    public GetDocumentTemplateByIdQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<DocumentTemplateDto> Handle(GetDocumentTemplateByIdQuery request, CancellationToken ct)
    {
        var t = await _context.DelegationDocumentTemplates
            .FirstOrDefaultAsync(t => t.Id == request.Id, ct)
            ?? throw new NotFoundException("DelegationDocumentTemplate", request.Id);

        return new DocumentTemplateDto(
            t.Id, t.Language, t.LanguageName, t.TemplateContent, t.Version, t.IsActive, t.CreatedAt, t.UpdatedAt);
    }
}

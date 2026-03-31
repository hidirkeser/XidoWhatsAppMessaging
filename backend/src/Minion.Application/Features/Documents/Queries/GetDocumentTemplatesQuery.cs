using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Documents.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Documents.Queries;

public record GetDocumentTemplatesQuery(string? Language = null) : IRequest<List<DocumentTemplateListDto>>;

public class GetDocumentTemplatesQueryHandler : IRequestHandler<GetDocumentTemplatesQuery, List<DocumentTemplateListDto>>
{
    private readonly IApplicationDbContext _context;

    public GetDocumentTemplatesQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<List<DocumentTemplateListDto>> Handle(GetDocumentTemplatesQuery request, CancellationToken ct)
    {
        var query = _context.DelegationDocumentTemplates.AsQueryable();

        if (!string.IsNullOrWhiteSpace(request.Language))
            query = query.Where(t => t.Language == request.Language);

        return await query
            .OrderBy(t => t.Language)
            .ThenByDescending(t => t.CreatedAt)
            .Select(t => new DocumentTemplateListDto(
                t.Id, t.Language, t.LanguageName, t.Version, t.IsActive, t.CreatedAt, t.UpdatedAt))
            .ToListAsync(ct);
    }
}

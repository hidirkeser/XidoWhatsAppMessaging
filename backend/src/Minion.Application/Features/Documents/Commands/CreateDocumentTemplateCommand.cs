using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Documents.DTOs;
using Minion.Domain.Entities;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Documents.Commands;

public record CreateDocumentTemplateCommand(
    string Language,
    string LanguageName,
    string TemplateContent,
    string Version) : IRequest<DocumentTemplateDto>;

public class CreateDocumentTemplateCommandHandler : IRequestHandler<CreateDocumentTemplateCommand, DocumentTemplateDto>
{
    private readonly IApplicationDbContext _context;

    public CreateDocumentTemplateCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<DocumentTemplateDto> Handle(CreateDocumentTemplateCommand request, CancellationToken ct)
    {
        // Deactivate any existing active template for this language
        var existing = await _context.DelegationDocumentTemplates
            .FirstOrDefaultAsync(t => t.Language == request.Language && t.IsActive, ct);

        if (existing != null)
            existing.IsActive = false;

        var template = new DelegationDocumentTemplate
        {
            Id = Guid.NewGuid(),
            Language = request.Language.ToLowerInvariant(),
            LanguageName = request.LanguageName,
            TemplateContent = request.TemplateContent,
            Version = request.Version,
            IsActive = true
        };

        _context.DelegationDocumentTemplates.Add(template);
        await _context.SaveChangesAsync(ct);

        return new DocumentTemplateDto(
            template.Id, template.Language, template.LanguageName,
            template.TemplateContent, template.Version, template.IsActive,
            template.CreatedAt, template.UpdatedAt);
    }
}

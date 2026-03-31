using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Documents.DTOs;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Documents.Commands;

public record UpdateDocumentTemplateCommand(
    Guid Id,
    string? LanguageName,
    string? TemplateContent,
    string? Version) : IRequest<DocumentTemplateDto>;

public class UpdateDocumentTemplateCommandHandler : IRequestHandler<UpdateDocumentTemplateCommand, DocumentTemplateDto>
{
    private readonly IApplicationDbContext _context;

    public UpdateDocumentTemplateCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<DocumentTemplateDto> Handle(UpdateDocumentTemplateCommand request, CancellationToken ct)
    {
        var template = await _context.DelegationDocumentTemplates
            .FirstOrDefaultAsync(t => t.Id == request.Id, ct)
            ?? throw new NotFoundException("DelegationDocumentTemplate", request.Id);

        if (request.LanguageName != null)
            template.LanguageName = request.LanguageName;

        if (request.TemplateContent != null)
            template.TemplateContent = request.TemplateContent;

        if (request.Version != null)
            template.Version = request.Version;

        await _context.SaveChangesAsync(ct);

        return new DocumentTemplateDto(
            template.Id, template.Language, template.LanguageName,
            template.TemplateContent, template.Version, template.IsActive,
            template.CreatedAt, template.UpdatedAt);
    }
}

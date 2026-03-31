using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Documents.Commands;

public record ToggleDocumentTemplateCommand(Guid Id) : IRequest<bool>;

public class ToggleDocumentTemplateCommandHandler : IRequestHandler<ToggleDocumentTemplateCommand, bool>
{
    private readonly IApplicationDbContext _context;

    public ToggleDocumentTemplateCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<bool> Handle(ToggleDocumentTemplateCommand request, CancellationToken ct)
    {
        var template = await _context.DelegationDocumentTemplates
            .FirstOrDefaultAsync(t => t.Id == request.Id, ct)
            ?? throw new NotFoundException("DelegationDocumentTemplate", request.Id);

        if (!template.IsActive)
        {
            // Deactivate any other active template for this language
            var otherActive = await _context.DelegationDocumentTemplates
                .FirstOrDefaultAsync(t => t.Language == template.Language && t.IsActive && t.Id != template.Id, ct);

            if (otherActive != null)
                otherActive.IsActive = false;
        }

        template.IsActive = !template.IsActive;
        await _context.SaveChangesAsync(ct);

        return template.IsActive;
    }
}

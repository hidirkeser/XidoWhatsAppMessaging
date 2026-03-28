using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Organizations.Commands;

public record DeleteOrganizationCommand(Guid Id) : IRequest<Unit>;

public class DeleteOrganizationCommandHandler : IRequestHandler<DeleteOrganizationCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly IAuditLogService _audit;

    public DeleteOrganizationCommandHandler(IApplicationDbContext context, IAuditLogService audit)
    {
        _context = context;
        _audit = audit;
    }

    public async Task<Unit> Handle(DeleteOrganizationCommand request, CancellationToken ct)
    {
        var org = await _context.Organizations
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(o => o.Id == request.Id, ct)
            ?? throw new NotFoundException("Organization", request.Id);

        org.IsDeleted = true;
        org.IsActive = false;
        await _context.SaveChangesAsync(ct);
        await _audit.LogAsync(AuditAction.OrganizationDelete, organizationId: org.Id, ct: ct);

        return Unit.Value;
    }
}

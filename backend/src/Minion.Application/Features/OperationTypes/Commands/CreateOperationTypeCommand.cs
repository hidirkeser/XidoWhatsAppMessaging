using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.OperationTypes.DTOs;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.OperationTypes.Commands;

public record CreateOperationTypeCommand(
    Guid OrganizationId, string Name, string? Description,
    string? Icon, int CreditCost, int SortOrder) : IRequest<OperationTypeDto>;

public class CreateOperationTypeCommandHandler : IRequestHandler<CreateOperationTypeCommand, OperationTypeDto>
{
    private readonly IApplicationDbContext _context;
    private readonly IAuditLogService _audit;

    public CreateOperationTypeCommandHandler(IApplicationDbContext context, IAuditLogService audit)
    {
        _context = context;
        _audit = audit;
    }

    public async Task<OperationTypeDto> Handle(CreateOperationTypeCommand request, CancellationToken ct)
    {
        var orgExists = await _context.Organizations.AnyAsync(o => o.Id == request.OrganizationId, ct);
        if (!orgExists) throw new NotFoundException("Organization", request.OrganizationId);

        var ot = new OperationType
        {
            Id = Guid.NewGuid(),
            OrganizationId = request.OrganizationId,
            Name = request.Name,
            Description = request.Description,
            Icon = request.Icon,
            CreditCost = request.CreditCost,
            SortOrder = request.SortOrder
        };

        _context.OperationTypes.Add(ot);
        await _context.SaveChangesAsync(ct);
        await _audit.LogAsync(AuditAction.OperationTypeCreate, organizationId: request.OrganizationId, ct: ct);

        return new OperationTypeDto(ot.Id, ot.OrganizationId, ot.Name, ot.Description,
            ot.Icon, ot.CreditCost, ot.IsActive, ot.SortOrder);
    }
}

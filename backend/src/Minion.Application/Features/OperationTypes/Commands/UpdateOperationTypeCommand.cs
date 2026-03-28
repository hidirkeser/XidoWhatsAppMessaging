using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.OperationTypes.DTOs;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.OperationTypes.Commands;

public record UpdateOperationTypeCommand(
    Guid Id, string? Name, string? Description, string? Icon,
    int? CreditCost, int? SortOrder) : IRequest<OperationTypeDto>;

public class UpdateOperationTypeCommandHandler : IRequestHandler<UpdateOperationTypeCommand, OperationTypeDto>
{
    private readonly IApplicationDbContext _context;
    private readonly IAuditLogService _audit;

    public UpdateOperationTypeCommandHandler(IApplicationDbContext context, IAuditLogService audit)
    {
        _context = context;
        _audit = audit;
    }

    public async Task<OperationTypeDto> Handle(UpdateOperationTypeCommand request, CancellationToken ct)
    {
        var ot = await _context.OperationTypes.FirstOrDefaultAsync(o => o.Id == request.Id, ct)
            ?? throw new NotFoundException("OperationType", request.Id);

        if (request.Name != null) ot.Name = request.Name;
        if (request.Description != null) ot.Description = request.Description;
        if (request.Icon != null) ot.Icon = request.Icon;
        if (request.CreditCost.HasValue) ot.CreditCost = request.CreditCost.Value;
        if (request.SortOrder.HasValue) ot.SortOrder = request.SortOrder.Value;

        await _context.SaveChangesAsync(ct);
        await _audit.LogAsync(AuditAction.OperationTypeUpdate, organizationId: ot.OrganizationId, ct: ct);

        return new OperationTypeDto(ot.Id, ot.OrganizationId, ot.Name, ot.Description,
            ot.Icon, ot.CreditCost, ot.IsActive, ot.SortOrder);
    }
}

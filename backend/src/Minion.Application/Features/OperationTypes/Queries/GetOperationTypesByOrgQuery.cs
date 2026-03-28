using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.OperationTypes.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.OperationTypes.Queries;

public record GetOperationTypesByOrgQuery(Guid OrganizationId) : IRequest<List<OperationTypeDto>>;

public class GetOperationTypesByOrgQueryHandler : IRequestHandler<GetOperationTypesByOrgQuery, List<OperationTypeDto>>
{
    private readonly IApplicationDbContext _context;

    public GetOperationTypesByOrgQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<List<OperationTypeDto>> Handle(GetOperationTypesByOrgQuery request, CancellationToken ct)
    {
        return await _context.OperationTypes
            .Where(ot => ot.OrganizationId == request.OrganizationId)
            .OrderBy(ot => ot.SortOrder)
            .Select(ot => new OperationTypeDto(ot.Id, ot.OrganizationId, ot.Name, ot.Description,
                ot.Icon, ot.CreditCost, ot.IsActive, ot.SortOrder))
            .ToListAsync(ct);
    }
}

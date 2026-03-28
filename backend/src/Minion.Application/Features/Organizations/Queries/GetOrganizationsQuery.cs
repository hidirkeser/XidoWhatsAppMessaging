using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Organizations.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Organizations.Queries;

public record GetOrganizationsQuery : IRequest<List<OrganizationDto>>;

public class GetOrganizationsQueryHandler : IRequestHandler<GetOrganizationsQuery, List<OrganizationDto>>
{
    private readonly IApplicationDbContext _context;

    public GetOrganizationsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<List<OrganizationDto>> Handle(GetOrganizationsQuery request, CancellationToken ct)
    {
        return await _context.Organizations
            .Where(o => o.IsActive)
            .OrderBy(o => o.Name)
            .Select(o => new OrganizationDto(o.Id, o.Name, o.OrgNumber, o.Address,
                o.City, o.PostalCode, o.ContactEmail, o.ContactPhone, o.IsActive, o.CreatedAt))
            .ToListAsync(ct);
    }
}

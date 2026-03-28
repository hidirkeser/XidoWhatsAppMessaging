using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Organizations.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Organizations.Queries;

public record GetMyOrganizationsQuery : IRequest<List<OrganizationDto>>;

public class GetMyOrganizationsQueryHandler : IRequestHandler<GetMyOrganizationsQuery, List<OrganizationDto>>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public GetMyOrganizationsQueryHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<List<OrganizationDto>> Handle(GetMyOrganizationsQuery request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        return await _context.UserOrganizations
            .Where(uo => uo.UserId == userId && uo.IsActive)
            .Select(uo => uo.Organization)
            .Where(o => o.IsActive)
            .Select(o => new OrganizationDto(o.Id, o.Name, o.OrgNumber, o.Address,
                o.City, o.PostalCode, o.ContactEmail, o.ContactPhone, o.IsActive, o.CreatedAt))
            .ToListAsync(ct);
    }
}

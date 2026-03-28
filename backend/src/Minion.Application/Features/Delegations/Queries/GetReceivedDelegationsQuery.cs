using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Common.Models;
using Minion.Application.Features.Delegations.DTOs;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Delegations.Queries;

public record GetReceivedDelegationsQuery(DelegationFilterDto Filter) : IRequest<PaginatedList<DelegationListItemDto>>;

public class GetReceivedDelegationsQueryHandler : IRequestHandler<GetReceivedDelegationsQuery, PaginatedList<DelegationListItemDto>>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public GetReceivedDelegationsQueryHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<PaginatedList<DelegationListItemDto>> Handle(GetReceivedDelegationsQuery request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();
        var f = request.Filter;

        var query = _context.Delegations
            .Include(d => d.GrantorUser)
            .Include(d => d.Organization)
            .Include(d => d.DelegationOperations)
            .Where(d => d.DelegateUserId == userId);

        if (!string.IsNullOrEmpty(f.Status) && Enum.TryParse<DelegationStatus>(f.Status, true, out var status))
            query = query.Where(d => d.Status == status);

        if (f.OrganizationId.HasValue)
            query = query.Where(d => d.OrganizationId == f.OrganizationId.Value);

        if (f.DateFrom.HasValue)
            query = query.Where(d => d.CreatedAt >= f.DateFrom.Value);

        if (f.DateTo.HasValue)
            query = query.Where(d => d.CreatedAt <= f.DateTo.Value);

        if (!string.IsNullOrEmpty(f.Search))
        {
            var s = f.Search.ToLower();
            query = query.Where(d =>
                d.GrantorUser.FirstName.ToLower().Contains(s) ||
                d.GrantorUser.LastName.ToLower().Contains(s) ||
                d.GrantorUser.PersonalNumber.Contains(s));
        }

        var projected = query
            .OrderByDescending(d => d.CreatedAt)
            .Select(d => new DelegationListItemDto(
                d.Id,
                d.GrantorUser.FirstName + " " + d.GrantorUser.LastName,
                d.Organization.Name,
                d.Status.ToString(),
                d.ValidFrom, d.ValidTo,
                d.DelegationOperations.Count,
                d.CreatedAt));

        return await PaginatedList<DelegationListItemDto>.CreateAsync(projected, f.Page, f.PageSize, ct);
    }
}

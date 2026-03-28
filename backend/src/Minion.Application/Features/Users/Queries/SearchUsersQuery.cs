using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Users.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Users.Queries;

public record SearchUsersQuery(string Query) : IRequest<List<UserSearchResultDto>>;

public class SearchUsersQueryHandler : IRequestHandler<SearchUsersQuery, List<UserSearchResultDto>>
{
    private readonly IApplicationDbContext _context;

    public SearchUsersQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<UserSearchResultDto>> Handle(SearchUsersQuery request, CancellationToken ct)
    {
        var q = request.Query.Trim().ToLower();

        var users = await _context.Users
            .Where(u => u.IsActive &&
                (u.PersonalNumber.Contains(q) ||
                 u.FirstName.ToLower().Contains(q) ||
                 u.LastName.ToLower().Contains(q) ||
                 (u.Email != null && u.Email.ToLower().Contains(q))))
            .Take(20)
            .Select(u => new UserSearchResultDto(u.Id, u.PersonalNumber, u.FirstName, u.LastName, u.Email))
            .ToListAsync(ct);

        return users;
    }
}

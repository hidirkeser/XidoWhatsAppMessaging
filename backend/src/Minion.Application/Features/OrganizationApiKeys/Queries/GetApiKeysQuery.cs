using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.OrganizationApiKeys.DTOs;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.OrganizationApiKeys.Queries;

public record GetApiKeysQuery(Guid OrganizationId) : IRequest<List<ApiKeyDto>>;

public class GetApiKeysQueryHandler : IRequestHandler<GetApiKeysQuery, List<ApiKeyDto>>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public GetApiKeysQueryHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<List<ApiKeyDto>> Handle(GetApiKeysQuery request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var isMember = await _context.UserOrganizations
            .AnyAsync(uo => uo.OrganizationId == request.OrganizationId
                         && uo.UserId == userId && uo.IsActive, ct);
        if (!isMember)
            throw new DomainException("Access denied.", "NOT_ORG_MEMBER");

        return await _context.OrganizationApiKeys
            .Where(k => k.OrganizationId == request.OrganizationId)
            .OrderByDescending(k => k.CreatedAt)
            .Select(k => new ApiKeyDto(k.Id, k.KeyId, k.Name, k.IsActive, k.LastUsedAt, k.RequestCount, k.CreatedAt))
            .ToListAsync(ct);
    }
}

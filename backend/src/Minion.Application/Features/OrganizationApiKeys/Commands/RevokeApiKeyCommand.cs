using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.OrganizationApiKeys.Commands;

public record RevokeApiKeyCommand(Guid OrganizationId, Guid KeyId) : IRequest;

public class RevokeApiKeyCommandHandler : IRequestHandler<RevokeApiKeyCommand>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public RevokeApiKeyCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task Handle(RevokeApiKeyCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var isMember = await _context.UserOrganizations
            .AnyAsync(uo => uo.OrganizationId == request.OrganizationId
                         && uo.UserId == userId && uo.IsActive, ct);
        if (!isMember)
            throw new DomainException("Access denied.", "NOT_ORG_MEMBER");

        var key = await _context.OrganizationApiKeys
            .FirstOrDefaultAsync(k => k.Id == request.KeyId
                               && k.OrganizationId == request.OrganizationId, ct)
            ?? throw new NotFoundException("OrganizationApiKey", request.KeyId);

        key.IsActive = false;
        await _context.SaveChangesAsync(ct);
    }
}

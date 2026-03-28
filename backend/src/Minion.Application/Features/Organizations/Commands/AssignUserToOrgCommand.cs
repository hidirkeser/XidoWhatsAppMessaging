using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Entities;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Organizations.Commands;

public record AssignUserToOrgCommand(Guid OrganizationId, Guid UserId, string Role = "Member") : IRequest<Unit>;

public class AssignUserToOrgCommandHandler : IRequestHandler<AssignUserToOrgCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public AssignUserToOrgCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<Unit> Handle(AssignUserToOrgCommand request, CancellationToken ct)
    {
        var exists = await _context.UserOrganizations
            .AnyAsync(uo => uo.UserId == request.UserId && uo.OrganizationId == request.OrganizationId, ct);
        if (exists) throw new DomainException("User is already assigned to this organization.");

        var orgExists = await _context.Organizations.AnyAsync(o => o.Id == request.OrganizationId, ct);
        if (!orgExists) throw new NotFoundException("Organization", request.OrganizationId);

        var userExists = await _context.Users.AnyAsync(u => u.Id == request.UserId, ct);
        if (!userExists) throw new NotFoundException("User", request.UserId);

        _context.UserOrganizations.Add(new UserOrganization
        {
            Id = Guid.NewGuid(),
            UserId = request.UserId,
            OrganizationId = request.OrganizationId,
            Role = request.Role,
            AssignedByUserId = _currentUser.UserId ?? throw new UnauthorizedAccessException()
        });

        await _context.SaveChangesAsync(ct);
        return Unit.Value;
    }
}

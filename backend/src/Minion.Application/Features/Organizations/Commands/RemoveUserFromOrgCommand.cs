using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Organizations.Commands;

public record RemoveUserFromOrgCommand(Guid OrganizationId, Guid UserId) : IRequest<Unit>;

public class RemoveUserFromOrgCommandHandler : IRequestHandler<RemoveUserFromOrgCommand, Unit>
{
    private readonly IApplicationDbContext _context;

    public RemoveUserFromOrgCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<Unit> Handle(RemoveUserFromOrgCommand request, CancellationToken ct)
    {
        var uo = await _context.UserOrganizations
            .FirstOrDefaultAsync(x => x.UserId == request.UserId && x.OrganizationId == request.OrganizationId, ct)
            ?? throw new NotFoundException("UserOrganization", $"{request.UserId}/{request.OrganizationId}");

        _context.UserOrganizations.Remove(uo);
        await _context.SaveChangesAsync(ct);
        return Unit.Value;
    }
}

using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Delegations.DTOs;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Delegations.Queries;

public record GetDelegationByIdQuery(Guid Id) : IRequest<DelegationDto>;

public class GetDelegationByIdQueryHandler : IRequestHandler<GetDelegationByIdQuery, DelegationDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public GetDelegationByIdQueryHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<DelegationDto> Handle(GetDelegationByIdQuery request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var d = await _context.Delegations
            .Include(d => d.GrantorUser)
            .Include(d => d.DelegateUser)
            .Include(d => d.Organization)
            .Include(d => d.DelegationOperations).ThenInclude(dop => dop.OperationType)
            .FirstOrDefaultAsync(d => d.Id == request.Id, ct)
            ?? throw new NotFoundException("Delegation", request.Id);

        if (d.GrantorUserId != userId && d.DelegateUserId != userId)
            throw new ForbiddenException();

        return new DelegationDto(
            d.Id, d.GrantorUserId, d.GrantorUser.FullName,
            d.DelegateUserId, d.DelegateUser.FullName,
            d.OrganizationId, d.Organization.Name,
            d.Status.ToString(), d.ValidFrom, d.ValidTo,
            d.CreditsDeducted, d.Notes,
            d.CreatedAt, d.AcceptedAt, d.RejectedAt, d.RevokedAt, d.ExpiredAt,
            d.DelegationOperations.Select(op => new DelegationOperationDto(
                op.Id, op.OperationTypeId, op.OperationType.Name, op.OperationType.Icon)).ToList());
    }
}

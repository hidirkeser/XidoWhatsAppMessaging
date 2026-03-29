using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Delegations.DTOs;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Delegations.Queries;

public record GetDelegationByVerificationCodeQuery(string Code) : IRequest<DelegationVerificationDto>;

public class GetDelegationByVerificationCodeQueryHandler : IRequestHandler<GetDelegationByVerificationCodeQuery, DelegationVerificationDto>
{
    private readonly IApplicationDbContext _context;

    public GetDelegationByVerificationCodeQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<DelegationVerificationDto> Handle(GetDelegationByVerificationCodeQuery request, CancellationToken ct)
    {
        var code = request.Code.ToUpperInvariant().Trim();

        var delegation = await _context.Delegations
            .Include(d => d.GrantorUser)
            .Include(d => d.DelegateUser)
            .Include(d => d.Organization)
            .Include(d => d.DelegationOperations)
                .ThenInclude(o => o.OperationType)
            .FirstOrDefaultAsync(d => d.VerificationCode == code, ct)
            ?? throw new NotFoundException("Delegation", code);

        return new DelegationVerificationDto(
            VerificationCode: delegation.VerificationCode,
            Status: delegation.Status.ToString(),
            GrantorFullName: delegation.GrantorUser.FullName,
            GrantorPersonalNumber: delegation.GrantorUser.PersonalNumber,
            DelegateFullName: delegation.DelegateUser.FullName,
            DelegatePersonalNumber: delegation.DelegateUser.PersonalNumber,
            OrganizationName: delegation.Organization.Name,
            Operations: delegation.DelegationOperations.Select(o => o.OperationType.Name).ToList(),
            ValidFrom: delegation.ValidFrom,
            ValidTo: delegation.ValidTo,
            IsBankIdSigned: !string.IsNullOrEmpty(delegation.BankIdSignature),
            IsActive: delegation.Status == DelegationStatus.Active
        );
    }
}

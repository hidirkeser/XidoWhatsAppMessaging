using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Delegations.DTOs;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Delegations.Commands;

public record InitDelegationVerificationCommand(string VerificationCode, string? EndUserIp) : IRequest<VerificationInitDto>;

public class InitDelegationVerificationCommandHandler : IRequestHandler<InitDelegationVerificationCommand, VerificationInitDto>
{
    private readonly IApplicationDbContext _context;
    private readonly IBankIdService _bankIdService;

    public InitDelegationVerificationCommandHandler(IApplicationDbContext context, IBankIdService bankIdService)
    {
        _context = context;
        _bankIdService = bankIdService;
    }

    public async Task<VerificationInitDto> Handle(InitDelegationVerificationCommand request, CancellationToken ct)
    {
        var code = request.VerificationCode.ToUpperInvariant().Trim();

        // Check delegation exists and is active
        var delegation = await _context.Delegations
            .Include(d => d.DelegateUser)
            .Include(d => d.Organization)
            .FirstOrDefaultAsync(d => d.VerificationCode == code, ct)
            ?? throw new NotFoundException("Delegation", code);

        // Build user-visible sign text
        var signText = $"Jag bekräftar att jag har kontrollerat fullmakt {code} " +
                       $"utfärdad till {delegation.DelegateUser.FirstName} {delegation.DelegateUser.LastName} " +
                       $"för {delegation.Organization.Name}.";

        var signResponse = await _bankIdService.InitSignAsync(request.EndUserIp, signText, ct);

        return new VerificationInitDto(
            signResponse.OrderRef,
            signResponse.AutoStartToken,
            signResponse.QrStartToken,
            signResponse.QrStartSecret
        );
    }
}

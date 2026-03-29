using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Delegations.DTOs;
using Minion.Domain.Entities;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Delegations.Commands;

public record CollectDelegationVerificationCommand(
    string VerificationCode,
    string OrderRef,
    string Channel,
    string? IpAddress
) : IRequest<VerificationCollectDto>;

public class CollectDelegationVerificationCommandHandler : IRequestHandler<CollectDelegationVerificationCommand, VerificationCollectDto>
{
    private readonly IApplicationDbContext _context;
    private readonly IBankIdService _bankIdService;

    public CollectDelegationVerificationCommandHandler(IApplicationDbContext context, IBankIdService bankIdService)
    {
        _context = context;
        _bankIdService = bankIdService;
    }

    public async Task<VerificationCollectDto> Handle(CollectDelegationVerificationCommand request, CancellationToken ct)
    {
        var code = request.VerificationCode.ToUpperInvariant().Trim();

        var collectResult = await _bankIdService.CollectAsync(request.OrderRef, ct);

        if (collectResult.Status == "pending")
            return new VerificationCollectDto("pending", collectResult.HintCode, null);

        if (collectResult.Status == "failed")
            return new VerificationCollectDto("failed", collectResult.HintCode, null);

        // Status == "complete" — save verification log
        var delegation = await _context.Delegations
            .FirstOrDefaultAsync(d => d.VerificationCode == code, ct)
            ?? throw new NotFoundException("Delegation", code);

        var personalNumber = collectResult.CompletionData?.PersonalNumber ?? "";
        var givenName = collectResult.CompletionData?.GivenName ?? "";
        var surname = collectResult.CompletionData?.Surname ?? "";
        var signature = collectResult.CompletionData?.Signature ?? "";

        var log = new DelegationVerificationLog
        {
            Id = Guid.NewGuid(),
            DelegationId = delegation.Id,
            VerifierPersonalNumber = personalNumber,
            VerifierFullName = $"{givenName} {surname}".Trim(),
            BankIdSignature = signature,
            Channel = request.Channel,
            IpAddress = request.IpAddress,
            VerifiedAt = DateTime.UtcNow
        };

        _context.DelegationVerificationLogs.Add(log);
        await _context.SaveChangesAsync(ct);

        return new VerificationCollectDto(
            "verified",
            null,
            new DelegationVerificationResultDto(
                log.VerifierFullName,
                log.VerifierPersonalNumber,
                log.VerifiedAt,
                log.Channel
            )
        );
    }
}

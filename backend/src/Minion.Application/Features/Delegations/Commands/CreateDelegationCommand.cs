using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Delegations.DTOs;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Delegations.Commands;

public record CreateDelegationCommand(
    Guid DelegateUserId,
    Guid OrganizationId,
    List<Guid> OperationTypeIds,
    string DurationType,
    int? DurationValue,
    DateTime? DateFrom,
    DateTime? DateTo,
    string? Notes,
    string? BankIdOrderRef = null,
    string? BankIdSignature = null) : IRequest<DelegationDto>;

public class CreateDelegationCommandHandler : IRequestHandler<CreateDelegationCommand, DelegationDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly ICreditService _creditService;
    private readonly IAuditLogService _audit;
    private readonly INotificationService _notification;

    public CreateDelegationCommandHandler(
        IApplicationDbContext context, ICurrentUserService currentUser,
        ICreditService creditService, IAuditLogService audit, INotificationService notification)
    {
        _context = context;
        _currentUser = currentUser;
        _creditService = creditService;
        _audit = audit;
        _notification = notification;
    }

    public async Task<DelegationDto> Handle(CreateDelegationCommand request, CancellationToken ct)
    {
        var grantorId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        if (grantorId == request.DelegateUserId)
            throw new DomainException("You cannot delegate to yourself.", "CANNOT_DELEGATE_TO_SELF");

        // Validate delegate user exists
        var delegateUser = await _context.Users.FirstOrDefaultAsync(u => u.Id == request.DelegateUserId && u.IsActive, ct)
            ?? throw new NotFoundException("User", request.DelegateUserId);

        var grantor = await _context.Users.FirstOrDefaultAsync(u => u.Id == grantorId, ct)
            ?? throw new NotFoundException("User", grantorId);

        // Validate organization
        var org = await _context.Organizations.FirstOrDefaultAsync(o => o.Id == request.OrganizationId && o.IsActive, ct)
            ?? throw new NotFoundException("Organization", request.OrganizationId);

        // Validate operation types and calculate credit cost
        var operationTypes = await _context.OperationTypes
            .Where(ot => request.OperationTypeIds.Contains(ot.Id) && ot.OrganizationId == request.OrganizationId && ot.IsActive)
            .ToListAsync(ct);

        if (operationTypes.Count != request.OperationTypeIds.Count)
            throw new DomainException("One or more operation types are invalid.", "INVALID_OPERATION_TYPES");

        var totalCreditCost = operationTypes.Sum(ot => ot.CreditCost);

        // Check credits
        if (!await _creditService.HasSufficientCreditsAsync(grantorId, totalCreditCost, ct))
        {
            var balance = await _creditService.GetBalanceAsync(grantorId, ct);
            throw new InsufficientCreditsException(totalCreditCost, balance);
        }

        // Calculate validity period
        var (validFrom, validTo) = CalculateValidity(request);

        // Create delegation
        var delegation = new Delegation
        {
            Id = Guid.NewGuid(),
            GrantorUserId = grantorId,
            DelegateUserId = request.DelegateUserId,
            OrganizationId = request.OrganizationId,
            Status = DelegationStatus.PendingApproval,
            ValidFrom = validFrom,
            ValidTo = validTo,
            CreditsDeducted = totalCreditCost,
            Notes = request.Notes,
            VerificationCode = GenerateVerificationCode(),
            BankIdOrderRef = request.BankIdOrderRef,
            BankIdSignature = request.BankIdSignature,
        };

        foreach (var otId in request.OperationTypeIds)
        {
            delegation.DelegationOperations.Add(new DelegationOperation
            {
                Id = Guid.NewGuid(),
                DelegationId = delegation.Id,
                OperationTypeId = otId
            });
        }

        _context.Delegations.Add(delegation);

        // Deduct credits
        await _creditService.DeductAsync(grantorId, totalCreditCost, delegation.Id, grantorId, ct);

        await _context.SaveChangesAsync(ct);

        // Audit
        await _audit.LogAsync(AuditAction.Grant, grantorId, grantor.FullName,
            targetUserId: request.DelegateUserId, organizationId: request.OrganizationId,
            delegationId: delegation.Id, ct: ct);

        // Notify delegate
        var opNames = string.Join(", ", operationTypes.Select(ot => ot.Name));
        await _notification.SendAsync(request.DelegateUserId,
            "Yeni yetki verildi",
            $"{grantor.FullName} sizi {org.Name} kurumu için {opNames} işlemlerine yetkilendirdi. ({validFrom:dd.MM.yyyy} - {validTo:dd.MM.yyyy})",
            NotificationType.DelegationGranted, delegation.Id, ct);

        return MapToDto(delegation, grantor, delegateUser, org, operationTypes);
    }

    private static (DateTime from, DateTime to) CalculateValidity(CreateDelegationCommand request)
    {
        var now = DateTime.UtcNow;

        if (request.DateFrom.HasValue && request.DateTo.HasValue)
            return (request.DateFrom.Value, request.DateTo.Value);

        if (request.DurationValue.HasValue)
        {
            var to = request.DurationType?.ToLower() switch
            {
                "minutes" or "dakika" => now.AddMinutes(request.DurationValue.Value),
                "hours" or "saat" => now.AddHours(request.DurationValue.Value),
                "days" or "gun" => now.AddDays(request.DurationValue.Value),
                _ => now.AddHours(request.DurationValue.Value)
            };
            return (now, to);
        }

        return (now, now.AddHours(1));
    }

    private static string GenerateVerificationCode()
    {
        const string chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // no ambiguous chars
        var random = new Random();
        var part1 = new string(Enumerable.Range(0, 4).Select(_ => chars[random.Next(chars.Length)]).ToArray());
        var part2 = new string(Enumerable.Range(0, 4).Select(_ => chars[random.Next(chars.Length)]).ToArray());
        return $"MIN-{part1}-{part2}";
    }

    private static DelegationDto MapToDto(Delegation d, User grantor, User delegateUser, Organization org, List<OperationType> ops)
    {
        return new DelegationDto(
            d.Id, d.GrantorUserId, grantor.FullName,
            d.DelegateUserId, delegateUser.FullName,
            d.OrganizationId, org.Name,
            d.Status.ToString(), d.ValidFrom, d.ValidTo,
            d.CreditsDeducted, d.Notes, d.RejectionNote,
            d.CreatedAt, d.AcceptedAt, d.RejectedAt, d.RevokedAt, d.ExpiredAt,
            ops.Select(ot => new DelegationOperationDto(ot.Id, ot.Id, ot.Name, ot.Icon)).ToList(),
            IsGrantorSigned: d.BankIdSignature != null,
            IsDelegateSigned: d.DelegateSignature != null);
    }
}

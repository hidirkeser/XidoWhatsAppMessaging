using Minion.Domain.Enums;

namespace Minion.Application.Features.Delegations.DTOs;

public record DelegationDto(
    Guid Id,
    Guid GrantorUserId, string GrantorName,
    Guid DelegateUserId, string DelegateName,
    Guid OrganizationId, string OrganizationName,
    string Status,
    DateTime ValidFrom, DateTime ValidTo,
    int CreditsDeducted, string? Notes,
    DateTime CreatedAt, DateTime? AcceptedAt, DateTime? RejectedAt,
    DateTime? RevokedAt, DateTime? ExpiredAt,
    List<DelegationOperationDto> Operations,
    bool IsGrantorSigned,
    bool IsDelegateSigned);

public record DelegationOperationDto(Guid Id, Guid OperationTypeId, string OperationName, string? Icon);

public record DelegationListItemDto(
    Guid Id,
    string CounterpartyName,
    string OrganizationName,
    string Status,
    DateTime ValidFrom, DateTime ValidTo,
    int OperationCount,
    DateTime CreatedAt);

public record CreateDelegationRequest(
    Guid DelegateUserId,
    Guid OrganizationId,
    List<Guid> OperationTypeIds,
    string DurationType,
    int? DurationValue,
    DateTime? DateFrom,
    DateTime? DateTo,
    string? Notes,
    string? BankIdOrderRef = null,
    string? BankIdSignature = null);

public record DelegationFilterDto(
    string? Status = null,
    Guid? OrganizationId = null,
    DateTime? DateFrom = null,
    DateTime? DateTo = null,
    string? Search = null,
    int Page = 1,
    int PageSize = 20);

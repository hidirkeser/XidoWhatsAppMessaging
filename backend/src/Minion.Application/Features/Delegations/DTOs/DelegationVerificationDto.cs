namespace Minion.Application.Features.Delegations.DTOs;

public record DelegationVerificationDto(
    string VerificationCode,
    string Status,
    string GrantorFullName,
    string GrantorPersonalNumber,
    string DelegateFullName,
    string DelegatePersonalNumber,
    string OrganizationName,
    List<string> Operations,
    DateTime ValidFrom,
    DateTime ValidTo,
    bool IsBankIdSigned,
    bool IsActive
);

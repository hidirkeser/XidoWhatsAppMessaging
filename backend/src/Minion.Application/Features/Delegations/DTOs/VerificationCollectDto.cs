namespace Minion.Application.Features.Delegations.DTOs;

public record VerificationCollectDto(
    string Status,           // "pending" | "verified" | "failed"
    string? Message,
    DelegationVerificationResultDto? Result
);

public record DelegationVerificationResultDto(
    string VerifierFullName,
    string VerifierPersonalNumber,
    DateTime VerifiedAt,
    string Channel
);

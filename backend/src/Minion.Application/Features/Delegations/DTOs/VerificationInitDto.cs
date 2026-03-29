namespace Minion.Application.Features.Delegations.DTOs;

public record VerificationInitDto(string OrderRef, string AutoStartToken, string QrStartToken, string QrStartSecret);

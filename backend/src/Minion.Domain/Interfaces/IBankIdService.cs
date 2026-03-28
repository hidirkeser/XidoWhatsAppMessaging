namespace Minion.Domain.Interfaces;

public interface IBankIdService
{
    Task<BankIdAuthResponse> InitAuthAsync(string? endUserIp, CancellationToken ct = default);
    Task<BankIdSignResponse> InitSignAsync(string? endUserIp, string userVisibleData, CancellationToken ct = default);
    Task<BankIdCollectResponse> CollectAsync(string orderRef, CancellationToken ct = default);
    Task CancelAsync(string orderRef, CancellationToken ct = default);
    string GenerateQrCode(string qrStartToken, string qrStartSecret, int elapsedSeconds);
}

public record BankIdAuthResponse(
    string OrderRef,
    string AutoStartToken,
    string QrStartToken,
    string QrStartSecret);

public record BankIdSignResponse(
    string OrderRef,
    string AutoStartToken,
    string QrStartToken,
    string QrStartSecret);

public record BankIdCollectResponse(
    string OrderRef,
    string Status,
    string? HintCode,
    BankIdCompletionData? CompletionData);

public record BankIdCompletionData(
    string PersonalNumber,
    string Name,
    string GivenName,
    string Surname,
    string Signature,
    string OcspResponse,
    string? BankIdIssueDate);

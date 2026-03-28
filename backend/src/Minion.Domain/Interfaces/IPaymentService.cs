using Minion.Domain.Enums;

namespace Minion.Domain.Interfaces;

public interface IPaymentService
{
    PaymentProvider Provider { get; }
    Task<PaymentInitResult> InitiatePaymentAsync(PaymentRequest request, CancellationToken ct = default);
    Task<PaymentStatusResult> CheckStatusAsync(string externalPaymentId, CancellationToken ct = default);
    Task<bool> ValidateCallbackAsync(string callbackData, CancellationToken ct = default);
}

public record PaymentRequest(
    Guid TransactionId,
    decimal AmountSEK,
    string Currency,
    string Description,
    string CallbackUrl,
    string ReturnUrl,
    string? PayerPhone = null);

public record PaymentInitResult(
    bool Success,
    string? ExternalPaymentId,
    string? PaymentUrl,
    string? QrData,
    string? ErrorMessage);

public record PaymentStatusResult(
    string ExternalPaymentId,
    PaymentStatus Status,
    string? ErrorMessage);

public interface IPaymentServiceFactory
{
    IPaymentService GetService(PaymentProvider provider);
}

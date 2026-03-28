using System.Globalization;
using Microsoft.Extensions.Logging;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services.Payment;

/// <summary>
/// Mock Swish service for development/testing without a real MSS certificate.
/// Simulates a successful PAID response after ~6 seconds (3 polls × 2s).
/// Switch to SwishPaymentService when you have the real test certificate.
/// </summary>
public class MockSwishPaymentService : IPaymentService
{
    private readonly ILogger<MockSwishPaymentService> _logger;

    // In-memory store: instructionId → (createdAt, status)
    private static readonly Dictionary<string, (DateTime CreatedAt, PaymentStatus Status)> _payments = new();

    public PaymentProvider Provider => PaymentProvider.Swish;

    public MockSwishPaymentService(ILogger<MockSwishPaymentService> logger)
    {
        _logger = logger;
    }

    public Task<PaymentInitResult> InitiatePaymentAsync(PaymentRequest request, CancellationToken ct = default)
    {
        var instructionId = Guid.NewGuid().ToString("N").ToUpper();
        var payeeAlias = "1234679304"; // MSS test merchant number

        _payments[instructionId] = (DateTime.UtcNow, PaymentStatus.Pending);

        _logger.LogInformation("[MOCK SWISH] Payment initiated. InstructionId: {Id}, Amount: {Amount} SEK",
            instructionId, request.AmountSEK);

        var amountStr = request.AmountSEK.ToString("F2", CultureInfo.InvariantCulture);
        var qrData =
            $"swish://payment?data={{\"version\":1," +
            $"\"payee\":{{\"value\":\"{payeeAlias}\",\"editable\":false}}," +
            $"\"amount\":{{\"value\":{amountStr},\"editable\":false}}," +
            $"\"message\":{{\"value\":\"Minion Test\",\"editable\":false}}}}";

        return Task.FromResult(new PaymentInitResult(
            Success: true,
            ExternalPaymentId: instructionId,
            PaymentUrl: null,
            QrData: qrData,
            ErrorMessage: null));
    }

    public Task<PaymentStatusResult> CheckStatusAsync(string externalPaymentId, CancellationToken ct = default)
    {
        if (!_payments.TryGetValue(externalPaymentId, out var entry))
        {
            _logger.LogWarning("[MOCK SWISH] Unknown instructionId: {Id}", externalPaymentId);
            return Task.FromResult(new PaymentStatusResult(externalPaymentId, PaymentStatus.Failed, "Not found"));
        }

        // Simulate: auto-PAID after 6 seconds
        var elapsed = DateTime.UtcNow - entry.CreatedAt;
        if (elapsed.TotalSeconds >= 6 && entry.Status == PaymentStatus.Pending)
        {
            _payments[externalPaymentId] = (entry.CreatedAt, PaymentStatus.Completed);
            _logger.LogInformation("[MOCK SWISH] Payment auto-completed. InstructionId: {Id}", externalPaymentId);
        }

        var status = _payments[externalPaymentId].Status;
        _logger.LogInformation("[MOCK SWISH] Status check: {Id} → {Status}", externalPaymentId, status);

        return Task.FromResult(new PaymentStatusResult(externalPaymentId, status, null));
    }

    public Task<bool> ValidateCallbackAsync(string callbackData, CancellationToken ct = default)
    {
        return Task.FromResult(true);
    }
}

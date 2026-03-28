using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services.Payment;

public class SwishPaymentService : IPaymentService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _config;
    private readonly ILogger<SwishPaymentService> _logger;

    public PaymentProvider Provider => PaymentProvider.Swish;

    public SwishPaymentService(HttpClient httpClient, IConfiguration config, ILogger<SwishPaymentService> logger)
    {
        _httpClient = httpClient;
        _config = config;
        _logger = logger;

        var baseUrl = config["Payment:Swish:BaseUrl"] ?? "https://mss.cpc.getswish.net/swish-cpcapi/api/v2/";
        _httpClient.BaseAddress = new Uri(baseUrl);
    }

    public async Task<PaymentInitResult> InitiatePaymentAsync(PaymentRequest request, CancellationToken ct = default)
    {
        try
        {
            var instructionId = Guid.NewGuid().ToString("N").ToUpper();
            var payeeAlias = _config["Payment:Swish:PayeeAlias"] ?? "1234679304";

            var swishRequest = new
            {
                payeePaymentReference = request.TransactionId.ToString(),
                callbackUrl = request.CallbackUrl,
                payeeAlias = payeeAlias,
                currency = "SEK",
                amount = request.AmountSEK.ToString("F2"),
                message = request.Description.Length > 50 ? request.Description[..50] : request.Description,
                payerAlias = request.PayerPhone
            };

            var response = await _httpClient.PutAsJsonAsync(
                $"paymentrequests/{instructionId}", swishRequest, ct);

            if (response.IsSuccessStatusCode)
            {
                var location = response.Headers.Location?.ToString();
                _logger.LogInformation("Swish payment initiated. InstructionId: {Id}", instructionId);

                return new PaymentInitResult(
                    Success: true,
                    ExternalPaymentId: instructionId,
                    PaymentUrl: null,
                    QrData: $"swish://payment?data={{\"version\":1,\"payee\":{{\"value\":\"{payeeAlias}\",\"editable\":false}},\"amount\":{{\"value\":{request.AmountSEK:F2},\"editable\":false}},\"message\":{{\"value\":\"{(request.Description.Length > 50 ? request.Description[..50] : request.Description)}\",\"editable\":false}}}}",
                    ErrorMessage: null);
            }

            var error = await response.Content.ReadAsStringAsync(ct);
            _logger.LogWarning("Swish payment failed: {Error}", error);
            return new PaymentInitResult(false, null, null, null, error);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Swish payment initiation failed");
            return new PaymentInitResult(false, null, null, null, ex.Message);
        }
    }

    public async Task<PaymentStatusResult> CheckStatusAsync(string externalPaymentId, CancellationToken ct = default)
    {
        var response = await _httpClient.GetAsync($"paymentrequests/{externalPaymentId}", ct);
        if (!response.IsSuccessStatusCode)
            return new PaymentStatusResult(externalPaymentId, PaymentStatus.Failed, "Could not retrieve status");

        var json = await response.Content.ReadFromJsonAsync<JsonElement>(cancellationToken: ct);
        var status = json.GetProperty("status").GetString();

        var mapped = status switch
        {
            "PAID" => PaymentStatus.Completed,
            "DECLINED" or "ERROR" => PaymentStatus.Failed,
            "CANCELLED" => PaymentStatus.Cancelled,
            _ => PaymentStatus.Pending
        };

        return new PaymentStatusResult(externalPaymentId, mapped, null);
    }

    public Task<bool> ValidateCallbackAsync(string callbackData, CancellationToken ct = default)
    {
        try
        {
            var json = JsonSerializer.Deserialize<JsonElement>(callbackData);
            if (json.TryGetProperty("status", out var statusProp))
            {
                var status = statusProp.GetString();
                return Task.FromResult(status == "PAID");
            }
            return Task.FromResult(false);
        }
        catch
        {
            return Task.FromResult(false);
        }
    }
}

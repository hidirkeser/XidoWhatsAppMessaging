using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services.Payment;

public class KlarnaPaymentService : IPaymentService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _config;
    private readonly ILogger<KlarnaPaymentService> _logger;

    public PaymentProvider Provider => PaymentProvider.Klarna;

    public KlarnaPaymentService(HttpClient httpClient, IConfiguration config, ILogger<KlarnaPaymentService> logger)
    {
        _httpClient = httpClient;
        _config = config;
        _logger = logger;

        var baseUrl = config["Payment:Klarna:BaseUrl"] ?? "https://api.playground.klarna.com/";
        _httpClient.BaseAddress = new Uri(baseUrl);

        var username = config["Payment:Klarna:Username"] ?? "";
        var password = config["Payment:Klarna:Password"] ?? "";
        var credentials = Convert.ToBase64String(Encoding.ASCII.GetBytes($"{username}:{password}"));
        _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", credentials);
    }

    public async Task<PaymentInitResult> InitiatePaymentAsync(PaymentRequest request, CancellationToken ct = default)
    {
        try
        {
            var sessionPayload = new
            {
                purchase_country = "SE",
                purchase_currency = "SEK",
                locale = "sv-SE",
                order_amount = (int)(request.AmountSEK * 100),
                order_tax_amount = 0,
                order_lines = new[]
                {
                    new
                    {
                        type = "digital",
                        reference = request.TransactionId.ToString(),
                        name = request.Description,
                        quantity = 1,
                        unit_price = (int)(request.AmountSEK * 100),
                        tax_rate = 0,
                        total_amount = (int)(request.AmountSEK * 100),
                        total_tax_amount = 0
                    }
                },
                merchant_urls = new
                {
                    confirmation = request.ReturnUrl,
                    notification = request.CallbackUrl
                }
            };

            var response = await _httpClient.PostAsJsonAsync("checkout/v3/orders", sessionPayload, ct);

            if (response.IsSuccessStatusCode)
            {
                var json = await response.Content.ReadFromJsonAsync<JsonElement>(cancellationToken: ct);
                var orderId = json.GetProperty("order_id").GetString();
                var htmlSnippet = json.TryGetProperty("html_snippet", out var snippet)
                    ? snippet.GetString() : null;

                _logger.LogInformation("Klarna order created. OrderId: {OrderId}", orderId);

                return new PaymentInitResult(
                    Success: true,
                    ExternalPaymentId: orderId,
                    PaymentUrl: null,
                    QrData: htmlSnippet,
                    ErrorMessage: null);
            }

            var error = await response.Content.ReadAsStringAsync(ct);
            _logger.LogWarning("Klarna payment failed: {Error}", error);
            return new PaymentInitResult(false, null, null, null, error);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Klarna payment initiation failed");
            return new PaymentInitResult(false, null, null, null, ex.Message);
        }
    }

    public async Task<PaymentStatusResult> CheckStatusAsync(string externalPaymentId, CancellationToken ct = default)
    {
        var response = await _httpClient.GetAsync($"checkout/v3/orders/{externalPaymentId}", ct);
        if (!response.IsSuccessStatusCode)
            return new PaymentStatusResult(externalPaymentId, PaymentStatus.Failed, "Could not retrieve status");

        var json = await response.Content.ReadFromJsonAsync<JsonElement>(cancellationToken: ct);
        var status = json.GetProperty("status").GetString();

        var mapped = status switch
        {
            "checkout_complete" => PaymentStatus.Completed,
            "checkout_incomplete" => PaymentStatus.Pending,
            _ => PaymentStatus.Pending
        };

        return new PaymentStatusResult(externalPaymentId, mapped, null);
    }

    public Task<bool> ValidateCallbackAsync(string callbackData, CancellationToken ct = default)
    {
        try
        {
            var json = JsonSerializer.Deserialize<JsonElement>(callbackData);
            var orderId = json.GetProperty("order_id").GetString();
            return Task.FromResult(orderId != null);
        }
        catch
        {
            return Task.FromResult(false);
        }
    }
}

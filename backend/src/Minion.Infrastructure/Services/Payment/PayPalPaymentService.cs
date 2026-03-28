using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services.Payment;

public class PayPalPaymentService : IPaymentService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _config;
    private readonly ILogger<PayPalPaymentService> _logger;
    private string? _accessToken;
    private DateTime _tokenExpiry = DateTime.MinValue;

    public PaymentProvider Provider => PaymentProvider.PayPal;

    public PayPalPaymentService(HttpClient httpClient, IConfiguration config, ILogger<PayPalPaymentService> logger)
    {
        _httpClient = httpClient;
        _config = config;
        _logger = logger;

        var baseUrl = config["Payment:PayPal:BaseUrl"] ?? "https://api-m.sandbox.paypal.com/";
        _httpClient.BaseAddress = new Uri(baseUrl);
    }

    private async Task EnsureAuthenticatedAsync(CancellationToken ct)
    {
        if (_accessToken != null && DateTime.UtcNow < _tokenExpiry) return;

        var clientId = _config["Payment:PayPal:ClientId"] ?? "";
        var clientSecret = _config["Payment:PayPal:ClientSecret"] ?? "";
        var credentials = Convert.ToBase64String(Encoding.ASCII.GetBytes($"{clientId}:{clientSecret}"));

        var request = new HttpRequestMessage(HttpMethod.Post, "v1/oauth2/token");
        request.Headers.Authorization = new AuthenticationHeaderValue("Basic", credentials);
        request.Content = new StringContent("grant_type=client_credentials", Encoding.UTF8, "application/x-www-form-urlencoded");

        var response = await _httpClient.SendAsync(request, ct);
        response.EnsureSuccessStatusCode();

        var json = await response.Content.ReadFromJsonAsync<JsonElement>(cancellationToken: ct);
        _accessToken = json.GetProperty("access_token").GetString();
        var expiresIn = json.GetProperty("expires_in").GetInt32();
        _tokenExpiry = DateTime.UtcNow.AddSeconds(expiresIn - 60);
    }

    public async Task<PaymentInitResult> InitiatePaymentAsync(PaymentRequest request, CancellationToken ct = default)
    {
        try
        {
            await EnsureAuthenticatedAsync(ct);

            var orderPayload = new
            {
                intent = "CAPTURE",
                purchase_units = new[]
                {
                    new
                    {
                        reference_id = request.TransactionId.ToString(),
                        description = request.Description,
                        amount = new
                        {
                            currency_code = "SEK",
                            value = request.AmountSEK.ToString("F2")
                        }
                    }
                },
                application_context = new
                {
                    return_url = request.ReturnUrl,
                    cancel_url = request.CallbackUrl + "?cancelled=true"
                }
            };

            var httpRequest = new HttpRequestMessage(HttpMethod.Post, "v2/checkout/orders");
            httpRequest.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _accessToken);
            httpRequest.Content = JsonContent.Create(orderPayload);

            var response = await _httpClient.SendAsync(httpRequest, ct);
            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadFromJsonAsync<JsonElement>(cancellationToken: ct);
            var orderId = json.GetProperty("id").GetString();
            var approveUrl = json.GetProperty("links").EnumerateArray()
                .FirstOrDefault(l => l.GetProperty("rel").GetString() == "approve")
                .GetProperty("href").GetString();

            _logger.LogInformation("PayPal order created. OrderId: {OrderId}", orderId);

            return new PaymentInitResult(
                Success: true,
                ExternalPaymentId: orderId,
                PaymentUrl: approveUrl,
                QrData: null,
                ErrorMessage: null);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "PayPal payment initiation failed");
            return new PaymentInitResult(false, null, null, null, ex.Message);
        }
    }

    public async Task<PaymentStatusResult> CheckStatusAsync(string externalPaymentId, CancellationToken ct = default)
    {
        await EnsureAuthenticatedAsync(ct);

        var request = new HttpRequestMessage(HttpMethod.Get, $"v2/checkout/orders/{externalPaymentId}");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _accessToken);

        var response = await _httpClient.SendAsync(request, ct);
        if (!response.IsSuccessStatusCode)
            return new PaymentStatusResult(externalPaymentId, PaymentStatus.Failed, "Could not retrieve status");

        var json = await response.Content.ReadFromJsonAsync<JsonElement>(cancellationToken: ct);
        var status = json.GetProperty("status").GetString();

        var mapped = status switch
        {
            "COMPLETED" => PaymentStatus.Completed,
            "APPROVED" => PaymentStatus.Pending,
            "VOIDED" => PaymentStatus.Cancelled,
            _ => PaymentStatus.Pending
        };

        return new PaymentStatusResult(externalPaymentId, mapped, null);
    }

    public async Task<bool> ValidateCallbackAsync(string callbackData, CancellationToken ct = default)
    {
        // PayPal uses capture flow - after buyer approves, we capture
        try
        {
            var json = JsonSerializer.Deserialize<JsonElement>(callbackData);
            var orderId = json.GetProperty("orderId").GetString();
            if (orderId == null) return false;

            await EnsureAuthenticatedAsync(ct);

            var request = new HttpRequestMessage(HttpMethod.Post, $"v2/checkout/orders/{orderId}/capture");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _accessToken);
            request.Content = new StringContent("{}", Encoding.UTF8, "application/json");

            var response = await _httpClient.SendAsync(request, ct);
            return response.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }
}

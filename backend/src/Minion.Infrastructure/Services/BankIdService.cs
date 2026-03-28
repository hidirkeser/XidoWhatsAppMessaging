using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services;

public class BankIdService : IBankIdService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<BankIdService> _logger;
    private readonly JsonSerializerOptions _jsonOptions;

    public BankIdService(HttpClient httpClient, IConfiguration configuration, ILogger<BankIdService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;

        var baseUrl = configuration["BankId:BaseUrl"] ?? "https://appapi2.test.bankid.com/rp/v6.0/";
        _httpClient.BaseAddress = new Uri(baseUrl);

        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
        };
    }

    private StringContent ToJsonContent(object obj)
    {
        var json = JsonSerializer.Serialize(obj, _jsonOptions);
        var content = new StringContent(json, Encoding.UTF8);
        content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
        return content;
    }

    public async Task<BankIdAuthResponse> InitAuthAsync(string? endUserIp, CancellationToken ct = default)
    {
        var request = new { endUserIp = endUserIp ?? "0.0.0.0" };
        var response = await _httpClient.PostAsync("auth", ToJsonContent(request), ct);
        response.EnsureSuccessStatusCode();

        var result = await JsonSerializer.DeserializeAsync<BankIdApiResponse>(
            await response.Content.ReadAsStreamAsync(ct), _jsonOptions, ct)
            ?? throw new InvalidOperationException("BankID auth response was null");

        _logger.LogInformation("BankID auth initiated. OrderRef: {OrderRef}", result.OrderRef);

        return new BankIdAuthResponse(
            result.OrderRef,
            result.AutoStartToken,
            result.QrStartToken,
            result.QrStartSecret);
    }

    public async Task<BankIdSignResponse> InitSignAsync(string? endUserIp, string userVisibleData, CancellationToken ct = default)
    {
        var encodedData = Convert.ToBase64String(Encoding.UTF8.GetBytes(userVisibleData));
        var request = new
        {
            endUserIp = endUserIp ?? "0.0.0.0",
            userVisibleData = encodedData,
            userVisibleDataFormat = "simpleMarkdownV1"
        };

        var response = await _httpClient.PostAsync("sign", ToJsonContent(request), ct);
        response.EnsureSuccessStatusCode();

        var result = await JsonSerializer.DeserializeAsync<BankIdApiResponse>(
            await response.Content.ReadAsStreamAsync(ct), _jsonOptions, ct)
            ?? throw new InvalidOperationException("BankID sign response was null");

        _logger.LogInformation("BankID sign initiated. OrderRef: {OrderRef}", result.OrderRef);

        return new BankIdSignResponse(
            result.OrderRef,
            result.AutoStartToken,
            result.QrStartToken,
            result.QrStartSecret);
    }

    public async Task<BankIdCollectResponse> CollectAsync(string orderRef, CancellationToken ct = default)
    {
        var request = new { orderRef };
        var response = await _httpClient.PostAsync("collect", ToJsonContent(request), ct);
        response.EnsureSuccessStatusCode();

        var result = await JsonSerializer.DeserializeAsync<BankIdCollectApiResponse>(
            await response.Content.ReadAsStreamAsync(ct), _jsonOptions, ct)
            ?? throw new InvalidOperationException("BankID collect response was null");

        BankIdCompletionData? completionData = null;
        if (result.CompletionData != null)
        {
            var user = result.CompletionData.User;
            completionData = new BankIdCompletionData(
                user.PersonalNumber,
                user.Name,
                user.GivenName,
                user.Surname,
                result.CompletionData.Signature,
                result.CompletionData.OcspResponse,
                result.CompletionData.BankIdIssueDate);
        }

        return new BankIdCollectResponse(
            result.OrderRef,
            result.Status,
            result.HintCode,
            completionData);
    }

    public async Task CancelAsync(string orderRef, CancellationToken ct = default)
    {
        var request = new { orderRef };
        var response = await _httpClient.PostAsync("cancel", ToJsonContent(request), ct);
        response.EnsureSuccessStatusCode();
        _logger.LogInformation("BankID order cancelled. OrderRef: {OrderRef}", orderRef);
    }

    public string GenerateQrCode(string qrStartToken, string qrStartSecret, int elapsedSeconds)
    {
        var keyBytes = Encoding.ASCII.GetBytes(qrStartSecret);
        var timeBytes = Encoding.ASCII.GetBytes(elapsedSeconds.ToString());
        using var hmac = new HMACSHA256(keyBytes);
        var hash = hmac.ComputeHash(timeBytes);
        var qrAuthCode = Convert.ToHexString(hash).ToLowerInvariant();
        return $"bankid.{qrStartToken}.{elapsedSeconds}.{qrAuthCode}";
    }

    private record BankIdApiResponse(
        string OrderRef,
        string AutoStartToken,
        string QrStartToken,
        string QrStartSecret);

    private record BankIdCollectApiResponse(
        string OrderRef,
        string Status,
        string? HintCode,
        BankIdCollectCompletionData? CompletionData);

    private record BankIdCollectCompletionData(
        BankIdCollectUser User,
        string Signature,
        string OcspResponse,
        string? BankIdIssueDate);

    private record BankIdCollectUser(
        string PersonalNumber,
        string Name,
        string GivenName,
        string Surname);
}

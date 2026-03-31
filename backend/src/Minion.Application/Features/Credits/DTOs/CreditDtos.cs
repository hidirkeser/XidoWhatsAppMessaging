using Minion.Domain.Enums;

namespace Minion.Application.Features.Credits.DTOs;

public record CreditBalanceDto(int Balance);

public record CreditPackageDto(
    Guid Id, string Name, int CreditAmount, decimal PriceSEK,
    string? Description, bool IsActive, int SortOrder);

public record CreditTransactionDto(
    Guid Id, string TransactionType, int Amount, int BalanceAfter,
    string? Description, DateTime CreatedAt);

public record PurchaseCreditsRequest(Guid CreditPackageId, string Provider, string? PayerPhone);

public record PurchaseCreditsResponse(
    Guid TransactionId, string Provider, string? PaymentUrl,
    string? QrData, string? ExternalPaymentId);

public record CreateCreditPackageRequest(
    string Name, string? NameSv, int CreditAmount, decimal PriceSEK,
    string? Description, string? DescriptionSv, string? Badge, string? BadgeSv,
    int SortOrder = 0);

public record UpdateCreditPackageRequest(
    string? Name, string? NameSv, int? CreditAmount, decimal? PriceSEK,
    string? Description, string? DescriptionSv, string? Badge, string? BadgeSv,
    int? SortOrder);

public record PaymentCallbackDto(string Provider, string TransactionId, string Data);

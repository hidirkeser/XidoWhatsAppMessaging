namespace Minion.Application.Features.Subscriptions.DTOs;

public record SubscriptionDto(
    Guid Id,
    Guid ProductId,
    string ProductName,
    string ProductType,
    DateTime StartDate,
    DateTime EndDate,
    int RemainingQuota,
    int MonthlyQuota,
    string Status,
    bool AutoRenew
);

public record PurchaseSubscriptionRequest(
    Guid ProductId,
    string Provider,
    string? PayerPhone
);

public record QuotaStatusDto(
    bool HasActiveSubscription,
    int RemainingQuota,
    int MonthlyQuota,
    DateTime? ExpiresAt,
    string? ProductName
);

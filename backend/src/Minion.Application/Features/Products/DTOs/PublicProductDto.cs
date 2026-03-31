namespace Minion.Application.Features.Products.DTOs;

public record PublicProductDto(
    Guid Id,
    string Name,
    string? Description,
    string ProductType,
    int MonthlyQuota,
    decimal PriceSEK,
    string[] Features,
    string? Badge,
    int SortOrder
);

public record PublicCreditPackageDto(
    Guid Id,
    string Name,
    int CreditAmount,
    decimal PriceSEK,
    string? Description,
    string? Badge,
    int SortOrder
);

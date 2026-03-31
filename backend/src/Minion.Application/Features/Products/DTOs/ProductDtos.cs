namespace Minion.Application.Features.Products.DTOs;

public record ProductDto(
    Guid Id,
    string Name,
    string? Description,
    string Type,
    int MonthlyQuota,
    decimal PriceSEK,
    string? Features,
    bool IsActive,
    int SortOrder
);

public record CreateProductRequest(
    string Name,
    string? Description,
    string Type,
    int MonthlyQuota,
    decimal PriceSEK,
    string? Features,
    int SortOrder = 0
);

public record UpdateProductRequest(
    string? Name,
    string? Description,
    string? Type,
    int? MonthlyQuota,
    decimal? PriceSEK,
    string? Features,
    int? SortOrder
);

namespace Minion.Application.Features.Credits.DTOs;

public record CreditPackageAdminDto(
    Guid Id,
    string Name,
    string? NameSv,
    int CreditAmount,
    decimal PriceSEK,
    string? Description,
    string? DescriptionSv,
    string? Badge,
    string? BadgeSv,
    bool IsActive,
    int SortOrder
);

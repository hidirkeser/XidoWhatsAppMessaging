namespace Minion.Application.Features.WebProducts.DTOs;

public record WebProductDto(
    Guid Id,
    string Slug,
    string Name,
    string Description,
    string[] Features,
    string Icon,
    string Color,
    int SortOrder
);

public record WebProductAdminDto(
    Guid Id,
    string Slug,
    string Icon,
    string Color,
    string NameEn,
    string DescriptionEn,
    string FeaturesEn,
    string NameSv,
    string DescriptionSv,
    string FeaturesSv,
    bool IsActive,
    int SortOrder
);

public record CreateWebProductRequest(
    string Slug,
    string Icon,
    string Color,
    string NameEn,
    string DescriptionEn,
    string FeaturesEn,
    string NameSv,
    string DescriptionSv,
    string FeaturesSv,
    int SortOrder = 0
);

public record UpdateWebProductRequest(
    string? Slug,
    string? Icon,
    string? Color,
    string? NameEn,
    string? DescriptionEn,
    string? FeaturesEn,
    string? NameSv,
    string? DescriptionSv,
    string? FeaturesSv,
    int? SortOrder
);

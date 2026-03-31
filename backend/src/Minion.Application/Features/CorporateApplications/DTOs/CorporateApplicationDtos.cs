namespace Minion.Application.Features.CorporateApplications.DTOs;

public record CorporateApplicationDto(
    Guid Id,
    string CompanyName,
    string OrgNumber,
    string ContactName,
    string ContactEmail,
    string? ContactPhone,
    string? DocumentPaths,
    string Status,
    string? ReviewNote,
    DateTime? ReviewedAt,
    string? ReviewedByName,
    DateTime CreatedAt
);

public record SubmitCorporateApplicationRequest(
    string CompanyName,
    string OrgNumber,
    string ContactName,
    string ContactEmail,
    string? ContactPhone,
    string? DocumentPaths
);

public record ReviewCorporateApplicationRequest(
    string? ReviewNote
);

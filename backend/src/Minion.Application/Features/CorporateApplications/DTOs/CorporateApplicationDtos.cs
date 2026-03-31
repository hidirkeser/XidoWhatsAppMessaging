namespace Minion.Application.Features.CorporateApplications.DTOs;

public record CorporateApplicationDto(
    Guid Id,
    string CompanyName,
    string OrgNumber,
    string ContactName,
    string ContactEmail,
    string? ContactPhone,
    string? DocumentPaths,
    string? DocumentsJson,
    string Status,
    string? ReviewNote,
    DateTime? ReviewedAt,
    string? ReviewedByName,
    int ResubmitCount,
    bool PhoneVerified,
    DateTime CreatedAt
);

public record SubmitCorporateApplicationRequest(
    string CompanyName,
    string OrgNumber,
    string ContactName,
    string ContactEmail,
    string? ContactPhone,
    string? DocumentPaths,
    string? DocumentsJson
);

public record ReviewCorporateApplicationRequest(
    string? ReviewNote
);

public record RequestDocumentsRequest(
    string Note
);

public record ResubmitApplicationRequest(
    string? DocumentsJson
);

public record SendOtpRequest(string Phone);
public record VerifyOtpRequest(string Phone, string Code);

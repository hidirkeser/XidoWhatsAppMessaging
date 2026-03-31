namespace Minion.Application.Features.Documents.DTOs;

public record DocumentTemplateDto(
    Guid Id,
    string Language,
    string LanguageName,
    string TemplateContent,
    string Version,
    bool IsActive,
    DateTime CreatedAt,
    DateTime? UpdatedAt);

public record DocumentTemplateListDto(
    Guid Id,
    string Language,
    string LanguageName,
    string Version,
    bool IsActive,
    DateTime CreatedAt,
    DateTime? UpdatedAt);

public record CreateDocumentTemplateRequest(
    string Language,
    string LanguageName,
    string TemplateContent,
    string Version);

public record UpdateDocumentTemplateRequest(
    string? LanguageName,
    string? TemplateContent,
    string? Version);

public record PreviewDocumentTemplateRequest(
    string TemplateContent);

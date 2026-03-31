namespace Minion.Application.Features.Documents.DTOs;

public record DelegationDocumentDto(
    Guid Id,
    Guid DelegationId,
    string Language,
    string RenderedContent,
    string DocumentVersion,
    string Status,
    DateTime? GrantorApprovedAt,
    bool IsGrantorSigned,
    DateTime? DelegateApprovedAt,
    bool IsDelegateSigned,
    string? QrCodeData,
    string GrantorName,
    string DelegateName,
    string OrganizationName,
    string VerificationCode,
    DateTime CreatedAt,
    DateTime? UpdatedAt);

public record DocumentLogDto(
    Guid Id,
    Guid? ActorUserId,
    string ActorName,
    string Action,
    string? Details,
    string? IpAddress,
    DateTime Timestamp);

public record ShareDocumentRequest(
    string ShareMethod,         // "qr", "link", "notification"
    string? RecipientPhone,
    string? RecipientEmail);

public record ApproveDocumentRequest(string BankIdSignature);

public record RejectDocumentRequest(string? Reason);

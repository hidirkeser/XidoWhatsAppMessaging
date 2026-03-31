using Minion.Domain.Entities;
using Minion.Domain.Enums;

namespace Minion.Domain.Interfaces;

public interface IDocumentService
{
    /// <summary>Generate a document from template for a delegation.</summary>
    Task<DelegationDocument> GenerateDocumentAsync(Guid delegationId, string language, CancellationToken ct = default);

    /// <summary>Get existing document for a delegation.</summary>
    Task<DelegationDocument?> GetByDelegationIdAsync(Guid delegationId, CancellationToken ct = default);

    /// <summary>Get document by verification code (public/QR access).</summary>
    Task<DelegationDocument?> GetByVerificationCodeAsync(string verificationCode, CancellationToken ct = default);

    /// <summary>Grantor approves the document with BankID signature.</summary>
    Task ApproveByGrantorAsync(Guid documentId, string bankIdSignature, string? ipAddress, CancellationToken ct = default);

    /// <summary>Delegate approves the document with BankID signature.</summary>
    Task ApproveByDelegateAsync(Guid documentId, string bankIdSignature, string? ipAddress, CancellationToken ct = default);

    /// <summary>Reject the document.</summary>
    Task RejectDocumentAsync(Guid documentId, Guid userId, string userName, string? reason, string? ipAddress, CancellationToken ct = default);

    /// <summary>Log a share event (QR shown, link copied, notification sent to 3rd party).</summary>
    Task ShareDocumentAsync(Guid documentId, Guid sharedByUserId, string sharedByName, string shareMethod, string? recipientInfo, string? ipAddress, CancellationToken ct = default);

    /// <summary>Log a third-party verification (after BankID verify on public page).</summary>
    Task LogThirdPartyVerificationAsync(Guid documentId, string verifierName, string verifierPersonalNumber, string? ipAddress, CancellationToken ct = default);

    /// <summary>Log a document view event.</summary>
    Task LogViewAsync(Guid documentId, Guid? viewerUserId, string viewerName, string? ipAddress, CancellationToken ct = default);

    /// <summary>Generate the QR code URL for a delegation document.</summary>
    string GenerateQrCodeUrl(string verificationCode);
}

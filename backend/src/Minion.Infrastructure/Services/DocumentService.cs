using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services;

public class DocumentService : IDocumentService
{
    private readonly IApplicationDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly ILogger<DocumentService> _logger;

    public DocumentService(
        IApplicationDbContext context,
        IConfiguration configuration,
        ILogger<DocumentService> logger)
    {
        _context = context;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<DelegationDocument> GenerateDocumentAsync(Guid delegationId, string language, CancellationToken ct = default)
    {
        // Check if document already exists
        var existing = await _context.DelegationDocuments
            .FirstOrDefaultAsync(d => d.DelegationId == delegationId, ct);
        if (existing != null)
            throw new DomainException("Document already exists for this delegation.", "DOCUMENT_ALREADY_EXISTS");

        // Load delegation with all related data
        var delegation = await _context.Delegations
            .Include(d => d.GrantorUser)
            .Include(d => d.DelegateUser)
            .Include(d => d.Organization)
            .Include(d => d.DelegationOperations)
                .ThenInclude(op => op.OperationType)
            .FirstOrDefaultAsync(d => d.Id == delegationId, ct)
            ?? throw new NotFoundException("Delegation", delegationId);

        // Load active template for requested language
        var template = await _context.DelegationDocumentTemplates
            .FirstOrDefaultAsync(t => t.Language == language && t.IsActive, ct)
            ?? await _context.DelegationDocumentTemplates
                .FirstOrDefaultAsync(t => t.Language == "en" && t.IsActive, ct)
            ?? throw new DomainException("No active document template found.", "TEMPLATE_NOT_FOUND");

        // Render template with delegation data
        var qrUrl = GenerateQrCodeUrl(delegation.VerificationCode);
        var operationNames = string.Join(", ",
            delegation.DelegationOperations.Select(op => op.OperationType.Name));

        var rendered = RenderTemplate(template.TemplateContent, delegation, operationNames, qrUrl);

        // Create document
        var document = new DelegationDocument
        {
            Id = Guid.NewGuid(),
            DelegationId = delegationId,
            Language = language,
            RenderedContent = rendered,
            DocumentVersion = template.Version,
            Status = DocumentStatus.PendingGrantorApproval,
            QrCodeData = qrUrl,
        };

        _context.DelegationDocuments.Add(document);

        // Log creation
        AddLog(document.Id, delegation.GrantorUserId, delegation.GrantorUser.FullName,
            DocumentLogAction.Created, $"Language: {language}, Template version: {template.Version}");

        await _context.SaveChangesAsync(ct);

        _logger.LogInformation("Document generated for DelegationId: {DelegationId}, Language: {Lang}",
            delegationId, language);

        return document;
    }

    public async Task<DelegationDocument?> GetByDelegationIdAsync(Guid delegationId, CancellationToken ct = default)
    {
        return await _context.DelegationDocuments
            .Include(d => d.Delegation)
                .ThenInclude(del => del.GrantorUser)
            .Include(d => d.Delegation)
                .ThenInclude(del => del.DelegateUser)
            .Include(d => d.Delegation)
                .ThenInclude(del => del.Organization)
            .FirstOrDefaultAsync(d => d.DelegationId == delegationId, ct);
    }

    public async Task<DelegationDocument?> GetByVerificationCodeAsync(string verificationCode, CancellationToken ct = default)
    {
        return await _context.DelegationDocuments
            .Include(d => d.Delegation)
                .ThenInclude(del => del.GrantorUser)
            .Include(d => d.Delegation)
                .ThenInclude(del => del.DelegateUser)
            .Include(d => d.Delegation)
                .ThenInclude(del => del.Organization)
            .Include(d => d.Delegation)
                .ThenInclude(del => del.DelegationOperations)
                    .ThenInclude(op => op.OperationType)
            .FirstOrDefaultAsync(d => d.Delegation.VerificationCode == verificationCode, ct);
    }

    public async Task ApproveByGrantorAsync(Guid documentId, string bankIdSignature, string? ipAddress, CancellationToken ct = default)
    {
        var doc = await _context.DelegationDocuments
            .Include(d => d.Delegation).ThenInclude(del => del.GrantorUser)
            .FirstOrDefaultAsync(d => d.Id == documentId, ct)
            ?? throw new NotFoundException("DelegationDocument", documentId);

        if (doc.GrantorApprovedAt.HasValue)
            throw new DomainException("Grantor has already approved this document.", "ALREADY_APPROVED");

        doc.GrantorSignature = bankIdSignature;
        doc.GrantorApprovedAt = DateTime.UtcNow;

        // If delegate already approved, mark as fully approved
        if (doc.DelegateApprovedAt.HasValue)
            doc.Status = DocumentStatus.FullyApproved;
        else
            doc.Status = DocumentStatus.PendingDelegateApproval;

        AddLog(doc.Id, doc.Delegation.GrantorUserId, doc.Delegation.GrantorUser.FullName,
            DocumentLogAction.GrantorApproved, null, ipAddress);

        await _context.SaveChangesAsync(ct);
        _logger.LogInformation("Grantor approved document {DocId}", documentId);
    }

    public async Task ApproveByDelegateAsync(Guid documentId, string bankIdSignature, string? ipAddress, CancellationToken ct = default)
    {
        var doc = await _context.DelegationDocuments
            .Include(d => d.Delegation).ThenInclude(del => del.DelegateUser)
            .FirstOrDefaultAsync(d => d.Id == documentId, ct)
            ?? throw new NotFoundException("DelegationDocument", documentId);

        if (doc.DelegateApprovedAt.HasValue)
            throw new DomainException("Delegate has already approved this document.", "ALREADY_APPROVED");

        doc.DelegateSignature = bankIdSignature;
        doc.DelegateApprovedAt = DateTime.UtcNow;

        // If grantor already approved, mark as fully approved
        if (doc.GrantorApprovedAt.HasValue)
            doc.Status = DocumentStatus.FullyApproved;
        else
            doc.Status = DocumentStatus.PendingGrantorApproval;

        AddLog(doc.Id, doc.Delegation.DelegateUserId, doc.Delegation.DelegateUser.FullName,
            DocumentLogAction.DelegateApproved, null, ipAddress);

        await _context.SaveChangesAsync(ct);
        _logger.LogInformation("Delegate approved document {DocId}", documentId);
    }

    public async Task RejectDocumentAsync(Guid documentId, Guid userId, string userName, string? reason, string? ipAddress, CancellationToken ct = default)
    {
        var doc = await _context.DelegationDocuments
            .FirstOrDefaultAsync(d => d.Id == documentId, ct)
            ?? throw new NotFoundException("DelegationDocument", documentId);

        if (doc.Status == DocumentStatus.FullyApproved)
            throw new DomainException("Cannot reject a fully approved document.", "CANNOT_REJECT_APPROVED");

        doc.Status = DocumentStatus.Rejected;

        AddLog(doc.Id, userId, userName, DocumentLogAction.Rejected, reason, ipAddress);

        await _context.SaveChangesAsync(ct);
        _logger.LogInformation("Document {DocId} rejected by {User}", documentId, userName);
    }

    public async Task ShareDocumentAsync(Guid documentId, Guid? sharedByUserId, string sharedByName, string shareMethod, string? recipientInfo, string? ipAddress, CancellationToken ct = default)
    {
        var doc = await _context.DelegationDocuments
            .FirstOrDefaultAsync(d => d.Id == documentId, ct)
            ?? throw new NotFoundException("DelegationDocument", documentId);

        var details = System.Text.Json.JsonSerializer.Serialize(new
        {
            method = shareMethod,       // "qr", "link", "notification"
            recipient = recipientInfo    // phone/email or null
        });

        AddLog(doc.Id, sharedByUserId, sharedByName, DocumentLogAction.SharedViaQr, details, ipAddress);

        await _context.SaveChangesAsync(ct);
        _logger.LogInformation("Document {DocId} shared via {Method} by {User}", documentId, shareMethod, sharedByName);
    }

    public async Task LogThirdPartyVerificationAsync(Guid documentId, string verifierName, string verifierPersonalNumber, string? ipAddress, CancellationToken ct = default)
    {
        var doc = await _context.DelegationDocuments
            .FirstOrDefaultAsync(d => d.Id == documentId, ct)
            ?? throw new NotFoundException("DelegationDocument", documentId);

        var details = System.Text.Json.JsonSerializer.Serialize(new
        {
            verifierPersonalNumber,
            verifierName
        });

        AddLog(doc.Id, null, verifierName, DocumentLogAction.ThirdPartyVerified, details, ipAddress);

        await _context.SaveChangesAsync(ct);
        _logger.LogInformation("Document {DocId} verified by third party: {Verifier}", documentId, verifierName);
    }

    public async Task LogViewAsync(Guid documentId, Guid? viewerUserId, string viewerName, string? ipAddress, CancellationToken ct = default)
    {
        AddLog(documentId, viewerUserId, viewerName, DocumentLogAction.Viewed, null, ipAddress);
        await _context.SaveChangesAsync(ct);
    }

    public string GenerateQrCodeUrl(string verificationCode)
    {
        var baseUrl = _configuration["AppBaseUrl"]?.TrimEnd('/') ?? "http://localhost:5131";
        return $"{baseUrl}/verify/{verificationCode}/document";
    }

    // ── Private helpers ──────────────────────────────────────────────────

    private string RenderTemplate(string template, Delegation delegation, string operationNames, string qrUrl)
    {
        return template
            .Replace("{{GrantorName}}", delegation.GrantorUser.FullName)
            .Replace("{{GrantorPersonalNumber}}", MaskPersonalNumber(delegation.GrantorUser.PersonalNumber))
            .Replace("{{DelegateName}}", delegation.DelegateUser.FullName)
            .Replace("{{DelegatePersonalNumber}}", MaskPersonalNumber(delegation.DelegateUser.PersonalNumber))
            .Replace("{{OrganizationName}}", delegation.Organization.Name)
            .Replace("{{OrganizationNumber}}", delegation.Organization.OrgNumber)
            .Replace("{{Operations}}", operationNames)
            .Replace("{{ValidFrom}}", delegation.ValidFrom.ToString("dd.MM.yyyy HH:mm"))
            .Replace("{{ValidTo}}", delegation.ValidTo.ToString("dd.MM.yyyy HH:mm"))
            .Replace("{{Notes}}", delegation.Notes ?? "-")
            .Replace("{{VerificationCode}}", delegation.VerificationCode)
            .Replace("{{CreatedAt}}", delegation.CreatedAt.ToString("dd.MM.yyyy HH:mm"))
            .Replace("{{DocumentVersion}}", "1.0")
            .Replace("{{QrCodeUrl}}", qrUrl);
    }

    private static string MaskPersonalNumber(string personalNumber)
    {
        // Show first 6 digits (birthdate), mask last 4: 199001011234 → 199001-****
        if (personalNumber.Length >= 10)
            return personalNumber[..8] + "-****";
        return personalNumber;
    }

    private void AddLog(Guid documentId, Guid? actorUserId, string actorName,
        DocumentLogAction action, string? details = null, string? ipAddress = null)
    {
        _context.DelegationDocumentLogs.Add(new DelegationDocumentLog
        {
            Id = Guid.NewGuid(),
            DelegationDocumentId = documentId,
            ActorUserId = actorUserId,
            ActorName = actorName,
            Action = action,
            Details = details,
            IpAddress = ipAddress,
            Timestamp = DateTime.UtcNow,
        });
    }
}

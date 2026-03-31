using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Documents.Commands;

public record ShareDocumentPublicCommand(
    string VerificationCode,
    string Method,            // "whatsapp" or "email"
    string? RecipientPhone,
    string? RecipientEmail,
    string SenderName,
    string? IpAddress) : IRequest;

public class ShareDocumentPublicCommandHandler : IRequestHandler<ShareDocumentPublicCommand>
{
    private readonly IApplicationDbContext _context;
    private readonly IDocumentService _documentService;
    private readonly IWhatsAppService _whatsAppService;
    private readonly IEmailService _emailService;

    public ShareDocumentPublicCommandHandler(
        IApplicationDbContext context,
        IDocumentService documentService,
        IWhatsAppService whatsAppService,
        IEmailService emailService)
    {
        _context = context;
        _documentService = documentService;
        _whatsAppService = whatsAppService;
        _emailService = emailService;
    }

    public async Task Handle(ShareDocumentPublicCommand request, CancellationToken ct)
    {
        var doc = await _documentService.GetByVerificationCodeAsync(request.VerificationCode, ct)
            ?? throw new NotFoundException("DelegationDocument", request.VerificationCode);

        if (doc.Status != DocumentStatus.FullyApproved)
            throw new DomainException("Only fully approved documents can be shared.", "DOCUMENT_NOT_APPROVED");

        var qrUrl = _documentService.GenerateQrCodeUrl(request.VerificationCode);
        var delegation = doc.Delegation;
        var recipientInfo = request.RecipientPhone ?? request.RecipientEmail;

        // Log the share event
        await _documentService.ShareDocumentAsync(
            doc.Id, null, request.SenderName, request.Method, recipientInfo, request.IpAddress, ct);

        var message = $"{request.SenderName} shared a power of attorney document with you.\n\n"
                    + $"Grantor: {delegation.GrantorUser.FullName}\n"
                    + $"Agent: {delegation.DelegateUser.FullName}\n"
                    + $"Organisation: {delegation.Organization.Name}\n\n"
                    + $"View document: {qrUrl}";

        if (request.Method == "whatsapp" && !string.IsNullOrWhiteSpace(request.RecipientPhone))
        {
            await _whatsAppService.SendAsync(request.RecipientPhone, $"Minion: {message}", ct);
        }
        else if (request.Method == "email" && !string.IsNullOrWhiteSpace(request.RecipientEmail))
        {
            await _emailService.SendAsync(
                request.RecipientEmail,
                "[Minion] Power of Attorney / Fullmakt",
                message, ct);
        }
    }
}

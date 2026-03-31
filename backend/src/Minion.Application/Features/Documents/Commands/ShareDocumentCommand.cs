using MediatR;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Minion.Application.Features.Documents.Commands;

public record ShareDocumentCommand(
    Guid DelegationId,
    string ShareMethod,       // "qr", "link", "notification"
    string? RecipientPhone,
    string? RecipientEmail,
    string? IpAddress) : IRequest<ShareDocumentResult>;

public record ShareDocumentResult(string QrCodeUrl, string VerificationCode);

public class ShareDocumentCommandHandler : IRequestHandler<ShareDocumentCommand, ShareDocumentResult>
{
    private readonly IApplicationDbContext _context;
    private readonly IDocumentService _documentService;
    private readonly ICurrentUserService _currentUser;
    private readonly INotificationService _notification;
    private readonly ISmsService _smsService;
    private readonly IWhatsAppService _whatsAppService;
    private readonly IEmailService _emailService;

    public ShareDocumentCommandHandler(
        IApplicationDbContext context,
        IDocumentService documentService,
        ICurrentUserService currentUser,
        INotificationService notification,
        ISmsService smsService,
        IWhatsAppService whatsAppService,
        IEmailService emailService)
    {
        _context = context;
        _documentService = documentService;
        _currentUser = currentUser;
        _notification = notification;
        _smsService = smsService;
        _whatsAppService = whatsAppService;
        _emailService = emailService;
    }

    public async Task<ShareDocumentResult> Handle(ShareDocumentCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var doc = await _context.DelegationDocuments
            .Include(d => d.Delegation).ThenInclude(del => del.GrantorUser)
            .Include(d => d.Delegation).ThenInclude(del => del.DelegateUser)
            .FirstOrDefaultAsync(d => d.DelegationId == request.DelegationId, ct)
            ?? throw new NotFoundException("DelegationDocument", request.DelegationId);

        var delegation = doc.Delegation;
        if (userId != delegation.GrantorUserId && userId != delegation.DelegateUserId)
            throw new DomainException("Only the grantor or delegate can share this document.", "NOT_AUTHORIZED");

        var sharedByName = userId == delegation.GrantorUserId
            ? delegation.GrantorUser.FullName
            : delegation.DelegateUser.FullName;

        var recipientInfo = request.RecipientPhone ?? request.RecipientEmail;

        // Log the share event
        await _documentService.ShareDocumentAsync(
            doc.Id, userId, sharedByName, request.ShareMethod, recipientInfo, request.IpAddress, ct);

        var qrUrl = _documentService.GenerateQrCodeUrl(delegation.VerificationCode);

        // Send notification to 3rd party if method is "notification"
        if (request.ShareMethod == "notification")
        {
            var message = $"{sharedByName} sizinle bir yetki belgesi paylasti. Belgeyi goruntulemek icin: {qrUrl}";

            if (!string.IsNullOrWhiteSpace(request.RecipientPhone))
            {
                await _smsService.SendAsync(request.RecipientPhone, $"Minion: {message}", ct);
                await _whatsAppService.SendAsync(request.RecipientPhone, $"Minion: {message}", ct);
            }

            if (!string.IsNullOrWhiteSpace(request.RecipientEmail))
            {
                await _emailService.SendAsync(request.RecipientEmail,
                    "[Minion] Yetki Belgesi Paylasimi", message, ct);
            }
        }

        return new ShareDocumentResult(qrUrl, delegation.VerificationCode);
    }
}

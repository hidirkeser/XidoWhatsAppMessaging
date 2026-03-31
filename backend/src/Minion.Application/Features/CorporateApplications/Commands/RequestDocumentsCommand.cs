using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.CorporateApplications.Commands;

public record RequestDocumentsCommand(Guid ApplicationId, string Note) : IRequest;

public class RequestDocumentsCommandHandler : IRequestHandler<RequestDocumentsCommand>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly IEmailService _emailService;
    private readonly ISmsService _smsService;
    private readonly IWhatsAppService _whatsAppService;

    public RequestDocumentsCommandHandler(
        IApplicationDbContext context, ICurrentUserService currentUser,
        IEmailService emailService, ISmsService smsService, IWhatsAppService whatsAppService)
    {
        _context = context;
        _currentUser = currentUser;
        _emailService = emailService;
        _smsService = smsService;
        _whatsAppService = whatsAppService;
    }

    public async Task Handle(RequestDocumentsCommand request, CancellationToken ct)
    {
        var adminId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var application = await _context.CorporateApplications
            .FirstOrDefaultAsync(a => a.Id == request.ApplicationId, ct)
            ?? throw new NotFoundException("CorporateApplication", request.ApplicationId);

        if (application.Status == CorporateApplicationStatus.Approved ||
            application.Status == CorporateApplicationStatus.Rejected)
            throw new DomainException("Başvuru zaten sonuçlandırılmış.", "ALREADY_REVIEWED");

        application.Status = CorporateApplicationStatus.DocumentsRequired;
        application.ReviewedByUserId = adminId;
        application.ReviewNote = request.Note;
        application.ReviewedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(ct);

        var body = $"Hej {application.ContactName},\n\n" +
                   $"Din företagsansökan för {application.CompanyName} kräver ytterligare dokument.\n\n" +
                   $"Anledning: {request.Note}\n\n" +
                   $"Logga in på Minion och ladda upp de begärda dokumenten.\n\nMinion-teamet";

        await _emailService.SendAsync(application.ContactEmail,
            "Komplettering krävs för företagsansökan - Minion", body, ct);

        if (!string.IsNullOrWhiteSpace(application.ContactPhone))
        {
            var smsBody = $"Minion: Företagsansökan för {application.CompanyName} kräver komplettering. " +
                          $"Anledning: {request.Note}. Logga in och ladda upp dokumenten.";

            await _smsService.SendAsync(application.ContactPhone, smsBody, ct);
            await _whatsAppService.SendAsync(application.ContactPhone, smsBody, ct);
        }
    }
}

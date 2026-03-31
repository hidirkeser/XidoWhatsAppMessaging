using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.CorporateApplications.Commands;

public record RejectCorporateApplicationCommand(Guid ApplicationId, string? ReviewNote) : IRequest;

public class RejectCorporateApplicationCommandHandler : IRequestHandler<RejectCorporateApplicationCommand>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly IEmailService _emailService;
    private readonly ISmsService _smsService;

    public RejectCorporateApplicationCommandHandler(
        IApplicationDbContext context, ICurrentUserService currentUser,
        IEmailService emailService, ISmsService smsService)
    {
        _context = context;
        _currentUser = currentUser;
        _emailService = emailService;
        _smsService = smsService;
    }

    public async Task Handle(RejectCorporateApplicationCommand request, CancellationToken ct)
    {
        var adminId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var application = await _context.CorporateApplications
            .FirstOrDefaultAsync(a => a.Id == request.ApplicationId, ct)
            ?? throw new NotFoundException("CorporateApplication", request.ApplicationId);

        if (application.Status != CorporateApplicationStatus.Pending)
            throw new DomainException("Application has already been reviewed.", "ALREADY_REVIEWED");

        application.Status = CorporateApplicationStatus.Rejected;
        application.ReviewedByUserId = adminId;
        application.ReviewNote = request.ReviewNote;
        application.ReviewedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(ct);

        // Notify applicant via email
        var reasonText = string.IsNullOrWhiteSpace(request.ReviewNote)
            ? ""
            : $"\n\nAnledning: {request.ReviewNote}";

        await _emailService.SendAsync(
            application.ContactEmail,
            "Företagsansökan avvisad - Minion",
            $"Hej {application.ContactName},\n\nTyvärr har din företagsansökan för {application.CompanyName} avvisats.{reasonText}" +
            $"\n\nKontakta oss om du har frågor.\nMinion-teamet",
            ct);

        // Notify via SMS if phone is available
        if (!string.IsNullOrWhiteSpace(application.ContactPhone))
        {
            await _smsService.SendAsync(
                application.ContactPhone,
                $"Minion: Din företagsansökan för {application.CompanyName} har tyvärr avvisats. Kontrollera din e-post för mer information.",
                ct);
        }
    }
}

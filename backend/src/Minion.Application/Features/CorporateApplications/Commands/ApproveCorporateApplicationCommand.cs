using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.CorporateApplications.Commands;

public record ApproveCorporateApplicationCommand(Guid ApplicationId, string? ReviewNote) : IRequest;

public class ApproveCorporateApplicationCommandHandler : IRequestHandler<ApproveCorporateApplicationCommand>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly INotificationService _notificationService;
    private readonly IEmailService _emailService;
    private readonly ISmsService _smsService;

    public ApproveCorporateApplicationCommandHandler(
        IApplicationDbContext context, ICurrentUserService currentUser,
        INotificationService notificationService, IEmailService emailService, ISmsService smsService)
    {
        _context = context;
        _currentUser = currentUser;
        _notificationService = notificationService;
        _emailService = emailService;
        _smsService = smsService;
    }

    public async Task Handle(ApproveCorporateApplicationCommand request, CancellationToken ct)
    {
        var adminId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var application = await _context.CorporateApplications
            .FirstOrDefaultAsync(a => a.Id == request.ApplicationId, ct)
            ?? throw new NotFoundException("CorporateApplication", request.ApplicationId);

        if (application.Status != CorporateApplicationStatus.Pending)
            throw new DomainException("Application has already been reviewed.", "ALREADY_REVIEWED");

        application.Status = CorporateApplicationStatus.Approved;
        application.ReviewedByUserId = adminId;
        application.ReviewNote = request.ReviewNote;
        application.ReviewedAt = DateTime.UtcNow;

        // Create organization from application
        var organization = new Organization
        {
            Id = Guid.NewGuid(),
            Name = application.CompanyName,
            OrgNumber = application.OrgNumber,
            ContactEmail = application.ContactEmail,
            ContactPhone = application.ContactPhone,
            CreatedByUserId = adminId
        };
        _context.Organizations.Add(organization);

        await _context.SaveChangesAsync(ct);

        // Notify applicant via email
        await _emailService.SendAsync(
            application.ContactEmail,
            "Företagsansökan godkänd - Minion",
            $"Hej {application.ContactName},\n\nDin företagsansökan för {application.CompanyName} har godkänts. " +
            $"Du kan nu logga in och börja använda våra företagstjänster.\n\nVälkommen!\nMinion-teamet",
            ct);

        // Notify applicant via SMS if phone is available
        if (!string.IsNullOrWhiteSpace(application.ContactPhone))
        {
            await _smsService.SendAsync(
                application.ContactPhone,
                $"Minion: Din företagsansökan för {application.CompanyName} har godkänts. Logga in för att komma igång.",
                ct);
        }
    }
}

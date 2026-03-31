using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.CorporateApplications.DTOs;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.CorporateApplications.Commands;

public record SubmitCorporateApplicationCommand(
    string CompanyName,
    string OrgNumber,
    string ContactName,
    string ContactEmail,
    string? ContactPhone,
    string? DocumentPaths,
    string? DocumentsJson
) : IRequest<CorporateApplicationDto>;

public class SubmitCorporateApplicationCommandHandler : IRequestHandler<SubmitCorporateApplicationCommand, CorporateApplicationDto>
{
    private readonly IApplicationDbContext _context;
    private readonly INotificationService _notificationService;

    public SubmitCorporateApplicationCommandHandler(IApplicationDbContext context, INotificationService notificationService)
    {
        _context = context;
        _notificationService = notificationService;
    }

    public async Task<CorporateApplicationDto> Handle(SubmitCorporateApplicationCommand request, CancellationToken ct)
    {
        // Require OTP phone verification if phone is provided
        if (!string.IsNullOrWhiteSpace(request.ContactPhone))
        {
            var verified = await _context.CorporateOtps
                .AnyAsync(o => o.Phone == request.ContactPhone && o.IsUsed
                    && o.ExpiresAt > DateTime.UtcNow.AddMinutes(-30), ct);
            // OTP must have been used (verified) within the last 30 minutes
            if (!verified)
                throw new Minion.Domain.Exceptions.DomainException(
                    "Telefon numarası doğrulanmamış. Lütfen OTP doğrulaması yapın.", "PHONE_NOT_VERIFIED");
        }

        var application = new CorporateApplication
        {
            Id = Guid.NewGuid(),
            CompanyName = request.CompanyName,
            OrgNumber = request.OrgNumber,
            ContactName = request.ContactName,
            ContactEmail = request.ContactEmail,
            ContactPhone = request.ContactPhone,
            DocumentPaths = request.DocumentPaths,
            DocumentsJson = request.DocumentsJson,
            PhoneVerified = !string.IsNullOrWhiteSpace(request.ContactPhone),
            Status = CorporateApplicationStatus.Pending
        };

        _context.CorporateApplications.Add(application);
        await _context.SaveChangesAsync(ct);

        // Notify all admins on all active channels
        var adminUsers = await _context.Users
            .Where(u => u.IsAdmin && u.IsActive)
            .Select(u => u.Id)
            .ToListAsync(ct);

        foreach (var adminId in adminUsers)
        {
            await _notificationService.SendAsync(adminId,
                "Ny företagsansökan",
                $"Ny företagsansökan från {request.CompanyName} ({request.OrgNumber}). Kontaktperson: {request.ContactName}.",
                NotificationType.CorporateApplicationReceived, application.Id, ct);
        }

        return new CorporateApplicationDto(application.Id, application.CompanyName, application.OrgNumber,
            application.ContactName, application.ContactEmail, application.ContactPhone,
            application.DocumentPaths, application.DocumentsJson, application.Status.ToString(),
            null, null, null, application.ResubmitCount, application.PhoneVerified, application.CreatedAt);
    }
}

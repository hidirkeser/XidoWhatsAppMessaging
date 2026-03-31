using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.CorporateApplications.Commands;

public record ResubmitApplicationCommand(
    Guid ApplicationId,
    string? DocumentsJson
) : IRequest;

public class ResubmitApplicationCommandHandler : IRequestHandler<ResubmitApplicationCommand>
{
    private const int MaxResubmits = 3;
    private readonly IApplicationDbContext _context;
    private readonly INotificationService _notificationService;

    public ResubmitApplicationCommandHandler(
        IApplicationDbContext context, INotificationService notificationService)
    {
        _context = context;
        _notificationService = notificationService;
    }

    public async Task Handle(ResubmitApplicationCommand request, CancellationToken ct)
    {
        var application = await _context.CorporateApplications
            .FirstOrDefaultAsync(a => a.Id == request.ApplicationId, ct)
            ?? throw new NotFoundException("CorporateApplication", request.ApplicationId);

        if (application.Status != CorporateApplicationStatus.DocumentsRequired)
            throw new DomainException("Başvuru belge bekleme durumunda değil.", "INVALID_STATUS");

        if (application.ResubmitCount >= MaxResubmits)
            throw new DomainException("Maksimum yeniden gönderim sayısına ulaşıldı.", "MAX_RESUBMIT");

        application.Status = CorporateApplicationStatus.Pending;
        application.DocumentsJson = request.DocumentsJson ?? application.DocumentsJson;
        application.ReviewNote = null;
        application.ReviewedAt = null;
        application.ResubmitCount++;
        application.LastResubmittedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(ct);

        // Notify admins that the application was resubmitted
        var adminIds = await _context.Users
            .Where(u => u.IsAdmin && u.IsActive)
            .Select(u => u.Id)
            .ToListAsync(ct);

        foreach (var adminId in adminIds)
        {
            await _notificationService.SendAsync(adminId,
                "Başvuru güncellendi",
                $"{application.CompanyName} eksik evraklarını tamamladı. Lütfen tekrar inceleyin.",
                NotificationType.CorporateApplicationReceived, application.Id, ct);
        }
    }
}

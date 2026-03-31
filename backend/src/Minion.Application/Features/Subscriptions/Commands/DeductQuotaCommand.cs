using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Subscriptions.Commands;

public record DeductQuotaCommand(Guid UserId, int Amount = 1) : IRequest;

public class DeductQuotaCommandHandler : IRequestHandler<DeductQuotaCommand>
{
    private readonly IApplicationDbContext _context;
    private readonly INotificationService _notificationService;

    public DeductQuotaCommandHandler(IApplicationDbContext context, INotificationService notificationService)
    {
        _context = context;
        _notificationService = notificationService;
    }

    public async Task Handle(DeductQuotaCommand request, CancellationToken ct)
    {
        var sub = await _context.UserSubscriptions
            .Include(s => s.Product)
            .Where(s => s.UserId == request.UserId && s.Status == SubscriptionStatus.Active && s.EndDate > DateTime.UtcNow)
            .OrderByDescending(s => s.EndDate)
            .FirstOrDefaultAsync(ct);

        if (sub == null)
            throw new QuotaExhaustedException(0, 0);

        if (sub.RemainingQuota < request.Amount)
            throw new QuotaExhaustedException(sub.Product.MonthlyQuota - sub.RemainingQuota, sub.Product.MonthlyQuota);

        sub.RemainingQuota -= request.Amount;
        await _context.SaveChangesAsync(ct);

        // Send low quota warning at 10%
        var threshold = (int)(sub.Product.MonthlyQuota * 0.1);
        if (sub.RemainingQuota > 0 && sub.RemainingQuota <= threshold)
        {
            await _notificationService.SendAsync(request.UserId,
                "Kota snart slut",
                $"Du har bara {sub.RemainingQuota} operationer kvar denna månad. Uppgradera din plan för att fortsätta.",
                NotificationType.QuotaLow, sub.Id, ct);
        }
    }
}

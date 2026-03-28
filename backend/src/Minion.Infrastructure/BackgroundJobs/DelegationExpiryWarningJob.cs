using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.BackgroundJobs;

public class DelegationExpiryWarningJob : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<DelegationExpiryWarningJob> _logger;

    public DelegationExpiryWarningJob(IServiceScopeFactory scopeFactory, ILogger<DelegationExpiryWarningJob> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessExpiringDelegationsAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing expiry warnings");
            }

            await Task.Delay(TimeSpan.FromMinutes(15), stoppingToken);
        }
    }

    private async Task ProcessExpiringDelegationsAsync(CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<IApplicationDbContext>();
        var notificationService = scope.ServiceProvider.GetRequiredService<INotificationService>();

        var warningThreshold = DateTime.UtcNow.AddHours(1);
        var alreadyWarnedIds = await context.Notifications
            .Where(n => n.Type == NotificationType.DelegationExpiringSoon)
            .Select(n => n.ReferenceId)
            .ToListAsync(ct);

        var expiring = await context.Delegations
            .Include(d => d.GrantorUser)
            .Include(d => d.DelegateUser)
            .Include(d => d.Organization)
            .Where(d => d.Status == DelegationStatus.Active
                && d.ValidTo <= warningThreshold
                && d.ValidTo > DateTime.UtcNow
                && !alreadyWarnedIds.Contains(d.Id))
            .ToListAsync(ct);

        foreach (var d in expiring)
        {
            var remaining = d.ValidTo - DateTime.UtcNow;
            var timeStr = remaining.TotalMinutes < 60
                ? $"{(int)remaining.TotalMinutes} dakika"
                : $"{(int)remaining.TotalHours} saat";

            await notificationService.SendAsync(d.GrantorUserId,
                "Yetki süresi dolmak üzere",
                $"{d.DelegateUser.FullName} için verdiğiniz yetki {timeStr} içinde dolacak.",
                NotificationType.DelegationExpiringSoon, d.Id, ct);

            await notificationService.SendAsync(d.DelegateUserId,
                "Yetki süresi dolmak üzere",
                $"{d.GrantorUser.FullName} tarafından verilen yetki {timeStr} içinde dolacak.",
                NotificationType.DelegationExpiringSoon, d.Id, ct);
        }

        if (expiring.Count > 0)
            _logger.LogInformation("Sent expiry warnings for {Count} delegations", expiring.Count);
    }
}

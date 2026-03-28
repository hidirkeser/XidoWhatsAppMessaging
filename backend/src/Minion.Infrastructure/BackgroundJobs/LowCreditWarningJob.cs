using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.BackgroundJobs;

public class LowCreditWarningJob : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<LowCreditWarningJob> _logger;
    private const int LowCreditThreshold = 5;

    public LowCreditWarningJob(IServiceScopeFactory scopeFactory, ILogger<LowCreditWarningJob> logger)
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
                await ProcessLowCreditWarningsAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing low credit warnings");
            }

            await Task.Delay(TimeSpan.FromHours(1), stoppingToken);
        }
    }

    private async Task ProcessLowCreditWarningsAsync(CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<IApplicationDbContext>();
        var notificationService = scope.ServiceProvider.GetRequiredService<INotificationService>();

        var oneDayAgo = DateTime.UtcNow.AddDays(-1);

        var lowCreditUsers = await context.UserCredits
            .Where(uc => uc.Balance > 0 && uc.Balance <= LowCreditThreshold)
            .Select(uc => uc.UserId)
            .ToListAsync(ct);

        var recentlyWarned = await context.Notifications
            .Where(n => n.Type == NotificationType.LowCreditWarning && n.CreatedAt > oneDayAgo)
            .Select(n => n.UserId)
            .Distinct()
            .ToListAsync(ct);

        var toWarn = lowCreditUsers.Except(recentlyWarned).ToList();

        foreach (var userId in toWarn)
        {
            var balance = await context.UserCredits
                .Where(uc => uc.UserId == userId)
                .Select(uc => uc.Balance)
                .FirstOrDefaultAsync(ct);

            await notificationService.SendAsync(userId,
                "Düşük kontör uyarısı",
                $"Kontör bakiyeniz {balance} adete düştü. Yetki verebilmek için kontör satın alın.",
                NotificationType.LowCreditWarning, ct: ct);
        }

        if (toWarn.Count > 0)
            _logger.LogInformation("Sent low credit warnings to {Count} users", toWarn.Count);
    }
}

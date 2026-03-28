using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.BackgroundJobs;

public class DelegationExpiryJob : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<DelegationExpiryJob> _logger;

    public DelegationExpiryJob(IServiceScopeFactory scopeFactory, ILogger<DelegationExpiryJob> logger)
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
                await ProcessExpiredDelegationsAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing expired delegations");
            }

            await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
        }
    }

    private async Task ProcessExpiredDelegationsAsync(CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<IApplicationDbContext>();
        var notificationService = scope.ServiceProvider.GetRequiredService<INotificationService>();
        var auditService = scope.ServiceProvider.GetRequiredService<IAuditLogService>();

        var expired = await context.Delegations
            .Include(d => d.GrantorUser)
            .Include(d => d.DelegateUser)
            .Include(d => d.Organization)
            .Where(d => d.Status == DelegationStatus.Active && d.ValidTo < DateTime.UtcNow)
            .ToListAsync(ct);

        foreach (var delegation in expired)
        {
            delegation.Status = DelegationStatus.Expired;
            delegation.ExpiredAt = DateTime.UtcNow;

            await auditService.LogAsync(AuditAction.Expire,
                delegationId: delegation.Id, organizationId: delegation.OrganizationId, ct: ct);

            await notificationService.SendAsync(delegation.GrantorUserId,
                "Yetki süresi doldu",
                $"{delegation.DelegateUser.FullName} için {delegation.Organization.Name} kurumundaki yetki süresi doldu.",
                NotificationType.DelegationExpired, delegation.Id, ct);

            await notificationService.SendAsync(delegation.DelegateUserId,
                "Yetki süresi doldu",
                $"{delegation.GrantorUser.FullName} tarafından verilen {delegation.Organization.Name} kurumundaki yetki süresi doldu.",
                NotificationType.DelegationExpired, delegation.Id, ct);
        }

        if (expired.Count > 0)
        {
            await context.SaveChangesAsync(ct);
            _logger.LogInformation("Expired {Count} delegations", expired.Count);
        }
    }
}

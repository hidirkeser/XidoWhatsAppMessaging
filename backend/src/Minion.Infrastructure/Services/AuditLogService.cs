using System.Text.Json;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services;

public class AuditLogService : IAuditLogService
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public AuditLogService(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task LogAsync(
        AuditAction action,
        Guid? actorUserId = null,
        string? actorName = null,
        Guid? targetUserId = null,
        Guid? organizationId = null,
        Guid? delegationId = null,
        object? details = null,
        CancellationToken ct = default)
    {
        var log = new AuditLog
        {
            Id = Guid.NewGuid(),
            Timestamp = DateTime.UtcNow,
            ActorUserId = actorUserId ?? _currentUser.UserId,
            ActorName = actorName,
            Action = action,
            TargetUserId = targetUserId,
            OrganizationId = organizationId,
            DelegationId = delegationId,
            Details = details != null ? JsonSerializer.Serialize(details) : null,
            IpAddress = _currentUser.IpAddress,
            UserAgent = _currentUser.UserAgent
        };

        _context.AuditLogs.Add(log);
        await _context.SaveChangesAsync(ct);
    }
}

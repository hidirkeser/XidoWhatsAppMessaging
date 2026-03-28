using Minion.Domain.Enums;

namespace Minion.Domain.Interfaces;

public interface IAuditLogService
{
    Task LogAsync(
        AuditAction action,
        Guid? actorUserId = null,
        string? actorName = null,
        Guid? targetUserId = null,
        Guid? organizationId = null,
        Guid? delegationId = null,
        object? details = null,
        CancellationToken ct = default);
}

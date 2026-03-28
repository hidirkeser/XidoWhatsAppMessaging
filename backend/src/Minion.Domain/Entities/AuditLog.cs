using Minion.Domain.Enums;

namespace Minion.Domain.Entities;

public class AuditLog
{
    public Guid Id { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    public Guid? ActorUserId { get; set; }
    public string? ActorName { get; set; }
    public AuditAction Action { get; set; }
    public Guid? TargetUserId { get; set; }
    public Guid? OrganizationId { get; set; }
    public Guid? DelegationId { get; set; }
    public string? Details { get; set; }
    public string? IpAddress { get; set; }
    public string? UserAgent { get; set; }
    public string? DeviceInfo { get; set; }

    public User? ActorUser { get; set; }
    public User? TargetUser { get; set; }
    public Organization? Organization { get; set; }
    public Delegation? Delegation { get; set; }
}

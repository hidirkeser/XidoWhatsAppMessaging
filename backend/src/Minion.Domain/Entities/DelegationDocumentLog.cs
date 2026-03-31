using Minion.Domain.Enums;

namespace Minion.Domain.Entities;

public class DelegationDocumentLog
{
    public Guid Id { get; set; }
    public Guid DelegationDocumentId { get; set; }
    public Guid? ActorUserId { get; set; }
    public string ActorName { get; set; } = string.Empty;
    public DocumentLogAction Action { get; set; }
    public string? Details { get; set; }
    public string? IpAddress { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    // Navigation
    public DelegationDocument DelegationDocument { get; set; } = null!;
}

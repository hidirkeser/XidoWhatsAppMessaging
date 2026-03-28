using Minion.Domain.Common;

namespace Minion.Domain.Entities;

public class UserOrganization : BaseEntity
{
    public Guid UserId { get; set; }
    public Guid OrganizationId { get; set; }
    public string Role { get; set; } = "Member";
    public DateTime AssignedAt { get; set; } = DateTime.UtcNow;
    public Guid AssignedByUserId { get; set; }
    public bool IsActive { get; set; } = true;

    public User User { get; set; } = null!;
    public Organization Organization { get; set; } = null!;
    public User AssignedByUser { get; set; } = null!;
}

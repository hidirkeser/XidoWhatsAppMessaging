using Minion.Domain.Common;

namespace Minion.Domain.Entities;

public class Organization : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string OrgNumber { get; set; } = string.Empty;
    public string? Address { get; set; }
    public string? City { get; set; }
    public string? PostalCode { get; set; }
    public string? ContactEmail { get; set; }
    public string? ContactPhone { get; set; }
    public bool IsActive { get; set; } = true;
    public bool IsDeleted { get; set; }
    public Guid CreatedByUserId { get; set; }

    public User CreatedByUser { get; set; } = null!;
    public ICollection<UserOrganization> UserOrganizations { get; set; } = new List<UserOrganization>();
    public ICollection<OperationType> OperationTypes { get; set; } = new List<OperationType>();
    public ICollection<Delegation> Delegations { get; set; } = new List<Delegation>();
}

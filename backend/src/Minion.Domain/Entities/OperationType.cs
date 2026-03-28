using Minion.Domain.Common;

namespace Minion.Domain.Entities;

public class OperationType : BaseEntity
{
    public Guid OrganizationId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Icon { get; set; }
    public int CreditCost { get; set; } = 1;
    public bool IsActive { get; set; } = true;
    public int SortOrder { get; set; }

    public Organization Organization { get; set; } = null!;
    public ICollection<DelegationOperation> DelegationOperations { get; set; } = new List<DelegationOperation>();
}

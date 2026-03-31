using Minion.Domain.Common;
using Minion.Domain.Enums;

namespace Minion.Domain.Entities;

public class Product : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public ProductType Type { get; set; }
    public int MonthlyQuota { get; set; }
    public decimal PriceSEK { get; set; }
    public string? Features { get; set; }
    public bool IsActive { get; set; } = true;
    public int SortOrder { get; set; }

    public ICollection<UserSubscription> Subscriptions { get; set; } = new List<UserSubscription>();
}

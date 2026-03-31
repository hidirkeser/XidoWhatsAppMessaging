using Minion.Domain.Common;
using Minion.Domain.Enums;

namespace Minion.Domain.Entities;

public class UserSubscription : BaseEntity
{
    public Guid UserId { get; set; }
    public Guid ProductId { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public int RemainingQuota { get; set; }
    public SubscriptionStatus Status { get; set; } = SubscriptionStatus.Active;
    public bool AutoRenew { get; set; }

    public User User { get; set; } = null!;
    public Product Product { get; set; } = null!;
}

using Minion.Domain.Common;
using Minion.Domain.Enums;

namespace Minion.Domain.Entities;

public class CreditTransaction : BaseEntity
{
    public Guid UserId { get; set; }
    public CreditTransactionType TransactionType { get; set; }
    public int Amount { get; set; }
    public int BalanceAfter { get; set; }
    public Guid? DelegationId { get; set; }
    public Guid? CreditPackageId { get; set; }
    public string? Description { get; set; }
    public Guid CreatedByUserId { get; set; }

    public User User { get; set; } = null!;
    public Delegation? Delegation { get; set; }
    public CreditPackage? CreditPackage { get; set; }
    public User CreatedByUser { get; set; } = null!;
}

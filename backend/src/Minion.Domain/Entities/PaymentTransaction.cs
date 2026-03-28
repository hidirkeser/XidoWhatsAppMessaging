using Minion.Domain.Common;
using Minion.Domain.Enums;

namespace Minion.Domain.Entities;

public class PaymentTransaction : BaseEntity
{
    public Guid UserId { get; set; }
    public Guid CreditPackageId { get; set; }
    public PaymentProvider Provider { get; set; }
    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;
    public decimal AmountSEK { get; set; }
    public int CreditAmount { get; set; }
    public string? ExternalPaymentId { get; set; }
    public string? ExternalOrderRef { get; set; }
    public string? CallbackData { get; set; }
    public DateTime? CompletedAt { get; set; }

    public User User { get; set; } = null!;
    public CreditPackage CreditPackage { get; set; } = null!;
}

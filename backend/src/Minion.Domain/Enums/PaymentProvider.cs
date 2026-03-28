namespace Minion.Domain.Enums;

public enum PaymentProvider
{
    Swish,
    PayPal,
    Klarna
}

public enum PaymentStatus
{
    Pending,
    Completed,
    Failed,
    Cancelled,
    Refunded
}

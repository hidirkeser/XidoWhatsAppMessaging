namespace Minion.Domain.Enums;

public enum NotificationType
{
    DelegationGranted,
    DelegationAccepted,
    DelegationRejected,
    DelegationRevoked,
    DelegationExpiringSoon,
    DelegationExpired,
    LowCreditWarning,
    CreditPurchaseSuccess
}

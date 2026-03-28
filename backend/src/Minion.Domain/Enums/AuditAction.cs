namespace Minion.Domain.Enums;

public enum AuditAction
{
    Login,
    Logout,
    Grant,
    Accept,
    Reject,
    Revoke,
    Execute,
    Expire,
    CreditPurchase,
    CreditDeduct,
    CreditManualAdd,
    CreditManualRemove,
    OrganizationCreate,
    OrganizationUpdate,
    OrganizationDelete,
    UserUpdate,
    OperationTypeCreate,
    OperationTypeUpdate
}

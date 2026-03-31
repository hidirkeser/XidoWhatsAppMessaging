namespace Minion.Domain.Enums;

public enum DocumentLogAction
{
    Created,
    Viewed,
    GrantorApproved,
    DelegateApproved,
    Rejected,
    Updated,
    Downloaded,
    SharedViaQr,
    ThirdPartyVerified,
    TemplateChanged
}

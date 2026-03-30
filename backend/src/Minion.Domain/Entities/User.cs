using Minion.Domain.Common;

namespace Minion.Domain.Entities;

public class User : BaseEntity
{
    public string PersonalNumber { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public bool IsAdmin { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime? LastLoginAt { get; set; }

    public string FullName => $"{FirstName} {LastName}";

    public DateTime? GdprConsentAcceptedAt { get; set; }
    public string? GdprConsentVersion { get; set; }
    public bool MarketingConsentAccepted { get; set; }

    public UserCredit? Credit { get; set; }
    public ICollection<UserOrganization> UserOrganizations { get; set; } = new List<UserOrganization>();
    public ICollection<Delegation> GrantedDelegations { get; set; } = new List<Delegation>();
    public ICollection<Delegation> ReceivedDelegations { get; set; } = new List<Delegation>();
    public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
    public ICollection<DeviceToken> DeviceTokens { get; set; } = new List<DeviceToken>();
    public ICollection<CreditTransaction> CreditTransactions { get; set; } = new List<CreditTransaction>();
    public UserNotificationPreference? NotificationPreference { get; set; }
}

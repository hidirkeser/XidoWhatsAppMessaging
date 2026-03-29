using Minion.Domain.Common;
using Minion.Domain.Enums;

namespace Minion.Domain.Entities;

public class Delegation : BaseEntity
{
    public Guid GrantorUserId { get; set; }
    public Guid DelegateUserId { get; set; }
    public Guid OrganizationId { get; set; }
    public DelegationStatus Status { get; set; } = DelegationStatus.PendingApproval;
    public DateTime ValidFrom { get; set; }
    public DateTime ValidTo { get; set; }
    public string? BankIdOrderRef { get; set; }
    public string? BankIdSignature { get; set; }
    public int CreditsDeducted { get; set; }
    public string? Notes { get; set; }
    public string VerificationCode { get; set; } = string.Empty;
    public DateTime? AcceptedAt { get; set; }
    public DateTime? RejectedAt { get; set; }
    public DateTime? RevokedAt { get; set; }
    public DateTime? ExpiredAt { get; set; }

    public User GrantorUser { get; set; } = null!;
    public User DelegateUser { get; set; } = null!;
    public Organization Organization { get; set; } = null!;
    public ICollection<DelegationOperation> DelegationOperations { get; set; } = new List<DelegationOperation>();
    public ICollection<DelegationVerificationLog> VerificationLogs { get; set; } = new List<DelegationVerificationLog>();
}

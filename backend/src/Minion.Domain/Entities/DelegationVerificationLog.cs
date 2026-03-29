namespace Minion.Domain.Entities;

public class DelegationVerificationLog
{
    public Guid Id { get; set; }
    public Guid DelegationId { get; set; }
    public Delegation Delegation { get; set; } = null!;

    public string VerifierPersonalNumber { get; set; } = string.Empty;
    public string VerifierFullName { get; set; } = string.Empty;
    public string BankIdSignature { get; set; } = string.Empty;
    public string Channel { get; set; } = "web";   // "web" | "app"
    public string? IpAddress { get; set; }
    public DateTime VerifiedAt { get; set; } = DateTime.UtcNow;
}

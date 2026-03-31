using Minion.Domain.Common;
using Minion.Domain.Enums;

namespace Minion.Domain.Entities;

public class CorporateApplication : BaseEntity
{
    public string CompanyName { get; set; } = string.Empty;
    public string OrgNumber { get; set; } = string.Empty;
    public string ContactName { get; set; } = string.Empty;
    public string ContactEmail { get; set; } = string.Empty;
    public string? ContactPhone { get; set; }
    public string? DocumentPaths { get; set; }   // legacy single string
    public string? DocumentsJson { get; set; }   // JSON: [{type, path, uploadedAt}]
    public CorporateApplicationStatus Status { get; set; } = CorporateApplicationStatus.Pending;
    public Guid? ReviewedByUserId { get; set; }
    public string? ReviewNote { get; set; }
    public DateTime? ReviewedAt { get; set; }
    public int ResubmitCount { get; set; } = 0;
    public DateTime? LastResubmittedAt { get; set; }
    // OTP phone verification
    public bool PhoneVerified { get; set; } = false;

    public User? ReviewedByUser { get; set; }
}

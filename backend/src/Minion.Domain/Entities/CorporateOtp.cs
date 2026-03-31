using Minion.Domain.Common;

namespace Minion.Domain.Entities;

public class CorporateOtp : BaseEntity
{
    public string Phone    { get; set; } = string.Empty;
    public string Code     { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public bool IsUsed     { get; set; } = false;
}

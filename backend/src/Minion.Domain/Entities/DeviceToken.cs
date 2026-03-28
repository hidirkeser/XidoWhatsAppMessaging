using Minion.Domain.Common;
using Minion.Domain.Enums;

namespace Minion.Domain.Entities;

public class DeviceToken : BaseEntity
{
    public Guid UserId { get; set; }
    public string Token { get; set; } = string.Empty;
    public DevicePlatform Platform { get; set; }
    public bool IsActive { get; set; } = true;

    public User User { get; set; } = null!;
}

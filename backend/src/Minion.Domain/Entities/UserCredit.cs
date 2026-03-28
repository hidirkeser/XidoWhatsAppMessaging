using Minion.Domain.Common;

namespace Minion.Domain.Entities;

public class UserCredit : BaseEntity
{
    public Guid UserId { get; set; }
    public int Balance { get; set; }

    public User User { get; set; } = null!;
}

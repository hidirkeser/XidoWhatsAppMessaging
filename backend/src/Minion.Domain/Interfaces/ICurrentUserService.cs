namespace Minion.Domain.Interfaces;

public interface ICurrentUserService
{
    Guid? UserId { get; }
    string? IpAddress { get; }
    string? UserAgent { get; }
    bool IsAuthenticated { get; }
}

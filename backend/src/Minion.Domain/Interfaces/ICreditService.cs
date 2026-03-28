namespace Minion.Domain.Interfaces;

public interface ICreditService
{
    Task<int> GetBalanceAsync(Guid userId, CancellationToken ct = default);
    Task<bool> HasSufficientCreditsAsync(Guid userId, int amount, CancellationToken ct = default);
    Task DeductAsync(Guid userId, int amount, Guid delegationId, Guid actionByUserId, CancellationToken ct = default);
    Task RefundAsync(Guid userId, int amount, Guid delegationId, Guid actionByUserId, CancellationToken ct = default);
    Task AddCreditsAsync(Guid userId, int amount, Guid creditPackageId, Guid actionByUserId, CancellationToken ct = default);
    Task ManualAdjustAsync(Guid userId, int amount, string description, Guid actionByUserId, CancellationToken ct = default);
}

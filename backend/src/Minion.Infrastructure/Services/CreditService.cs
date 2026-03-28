using Microsoft.EntityFrameworkCore;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;
using Minion.Infrastructure.Persistence;

namespace Minion.Infrastructure.Services;

public class CreditService : ICreditService
{
    private readonly ApplicationDbContext _context;

    public CreditService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<int> GetBalanceAsync(Guid userId, CancellationToken ct = default)
    {
        var credit = await _context.UserCredits.FirstOrDefaultAsync(c => c.UserId == userId, ct);
        return credit?.Balance ?? 0;
    }

    public async Task<bool> HasSufficientCreditsAsync(Guid userId, int amount, CancellationToken ct = default)
    {
        var balance = await GetBalanceAsync(userId, ct);
        return balance >= amount;
    }

    public async Task DeductAsync(Guid userId, int amount, Guid delegationId, Guid actionByUserId, CancellationToken ct = default)
    {
        await using var transaction = await _context.Database.BeginTransactionAsync(ct);

        var credit = await _context.UserCredits
            .FromSqlRaw("SELECT * FROM \"UserCredits\" WHERE \"UserId\" = {0} FOR UPDATE", userId)
            .FirstOrDefaultAsync(ct)
            ?? throw new NotFoundException("UserCredit", userId);

        if (credit.Balance < amount)
            throw new InsufficientCreditsException(amount, credit.Balance);

        credit.Balance -= amount;
        credit.UpdatedAt = DateTime.UtcNow;

        _context.CreditTransactions.Add(new CreditTransaction
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TransactionType = CreditTransactionType.Deduct,
            Amount = -amount,
            BalanceAfter = credit.Balance,
            DelegationId = delegationId,
            CreatedByUserId = actionByUserId,
            Description = "Delegation credit deduction"
        });

        await _context.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);
    }

    public async Task RefundAsync(Guid userId, int amount, Guid delegationId, Guid actionByUserId, CancellationToken ct = default)
    {
        var credit = await _context.UserCredits.FirstOrDefaultAsync(c => c.UserId == userId, ct)
            ?? throw new NotFoundException("UserCredit", userId);

        credit.Balance += amount;
        credit.UpdatedAt = DateTime.UtcNow;

        _context.CreditTransactions.Add(new CreditTransaction
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TransactionType = CreditTransactionType.Refund,
            Amount = amount,
            BalanceAfter = credit.Balance,
            DelegationId = delegationId,
            CreatedByUserId = actionByUserId,
            Description = "Delegation credit refund"
        });

        await _context.SaveChangesAsync(ct);
    }

    public async Task AddCreditsAsync(Guid userId, int amount, Guid creditPackageId, Guid actionByUserId, CancellationToken ct = default)
    {
        var credit = await _context.UserCredits.FirstOrDefaultAsync(c => c.UserId == userId, ct);
        if (credit == null)
        {
            credit = new UserCredit { Id = Guid.NewGuid(), UserId = userId, Balance = 0 };
            _context.UserCredits.Add(credit);
        }

        credit.Balance += amount;
        credit.UpdatedAt = DateTime.UtcNow;

        _context.CreditTransactions.Add(new CreditTransaction
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TransactionType = CreditTransactionType.Purchase,
            Amount = amount,
            BalanceAfter = credit.Balance,
            CreditPackageId = creditPackageId,
            CreatedByUserId = actionByUserId,
            Description = "Credit package purchase"
        });

        await _context.SaveChangesAsync(ct);
    }

    public async Task ManualAdjustAsync(Guid userId, int amount, string description, Guid actionByUserId, CancellationToken ct = default)
    {
        var credit = await _context.UserCredits.FirstOrDefaultAsync(c => c.UserId == userId, ct);
        if (credit == null)
        {
            credit = new UserCredit { Id = Guid.NewGuid(), UserId = userId, Balance = 0 };
            _context.UserCredits.Add(credit);
        }

        credit.Balance += amount;
        credit.UpdatedAt = DateTime.UtcNow;

        _context.CreditTransactions.Add(new CreditTransaction
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TransactionType = amount >= 0 ? CreditTransactionType.ManualAdd : CreditTransactionType.ManualRemove,
            Amount = amount,
            BalanceAfter = credit.Balance,
            CreatedByUserId = actionByUserId,
            Description = description
        });

        await _context.SaveChangesAsync(ct);
    }
}

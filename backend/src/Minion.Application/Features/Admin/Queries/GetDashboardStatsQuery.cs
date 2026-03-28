using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Admin.DTOs;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Admin.Queries;

public record GetDashboardStatsQuery : IRequest<DashboardStatsDto>;

public class GetDashboardStatsQueryHandler : IRequestHandler<GetDashboardStatsQuery, DashboardStatsDto>
{
    private readonly IApplicationDbContext _context;

    public GetDashboardStatsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<DashboardStatsDto> Handle(GetDashboardStatsQuery request, CancellationToken ct)
    {
        var totalUsers = await _context.Users.CountAsync(u => u.IsActive, ct);
        var totalOrgs = await _context.Organizations.CountAsync(ct);

        var delegationStats = await _context.Delegations
            .GroupBy(d => d.Status)
            .Select(g => new DelegationsByStatusDto(g.Key.ToString(), g.Count()))
            .ToListAsync(ct);

        var activeDelegations = delegationStats.FirstOrDefault(s => s.Status == "Active")?.Count ?? 0;
        var pendingDelegations = delegationStats.FirstOrDefault(s => s.Status == "PendingApproval")?.Count ?? 0;
        var totalDelegations = delegationStats.Sum(s => s.Count);

        var creditStats = await _context.CreditTransactions
            .Where(t => t.TransactionType == CreditTransactionType.Purchase)
            .GroupBy(_ => 1)
            .Select(g => new { TotalAmount = g.Sum(t => t.Amount) })
            .FirstOrDefaultAsync(ct);

        var totalRevenue = await _context.PaymentTransactions
            .Where(p => p.Status == PaymentStatus.Completed)
            .SumAsync(p => p.AmountSEK, ct);

        return new DashboardStatsDto(
            totalUsers, totalOrgs, activeDelegations, pendingDelegations,
            totalDelegations, creditStats?.TotalAmount ?? 0, totalRevenue,
            delegationStats);
    }
}

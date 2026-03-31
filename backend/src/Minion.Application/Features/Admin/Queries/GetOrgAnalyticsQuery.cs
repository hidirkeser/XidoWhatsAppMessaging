using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Admin.Queries;

public record GetOrgAnalyticsQuery(
    Guid? OrgId,
    DateTime DateFrom,
    DateTime DateTo,
    string Granularity   // "daily" | "weekly" | "monthly" | "yearly"
) : IRequest<OrgAnalyticsDto>;

public record OrgAnalyticsDto(
    List<OrgSummaryDto> OrgSummaries,
    List<AnalyticsDataPoint> Chart,
    int TotalDelegations,
    int TotalCreditsUsed,
    decimal TotalRevenueSEK,
    int TotalApplications
);

public record OrgSummaryDto(Guid OrgId, string OrgName, int Delegations, int CreditsUsed, decimal RevenueSEK);
public record AnalyticsDataPoint(string Label, int Delegations, int CreditsUsed, decimal RevenueSEK);

internal record DelegationRow(Guid OrganizationId, DateTime CreatedAt, int CreditsDeducted);
internal record PaymentRow(decimal AmountSEK, DateTime? CompletedAt);

public class GetOrgAnalyticsQueryHandler : IRequestHandler<GetOrgAnalyticsQuery, OrgAnalyticsDto>
{
    private readonly IApplicationDbContext _context;

    public GetOrgAnalyticsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<OrgAnalyticsDto> Handle(GetOrgAnalyticsQuery request, CancellationToken ct)
    {
        var dateTo = request.DateTo.Date.AddDays(1).AddTicks(-1);

        // Delegations in range
        var delegationsQuery = _context.Delegations
            .Where(d => d.CreatedAt >= request.DateFrom && d.CreatedAt <= dateTo);
        if (request.OrgId.HasValue)
            delegationsQuery = delegationsQuery.Where(d => d.OrganizationId == request.OrgId.Value);

        var delegations = await delegationsQuery
            .Select(d => new DelegationRow(d.OrganizationId, d.CreatedAt, d.CreditsDeducted))
            .ToListAsync(ct);

        // Payments in range
        var paymentsQuery = _context.PaymentTransactions
            .Where(p => p.Status == PaymentStatus.Completed
                     && p.CompletedAt >= request.DateFrom
                     && p.CompletedAt <= dateTo);
        if (request.OrgId.HasValue)
        {
            var memberIds = await _context.UserOrganizations
                .Where(uo => uo.OrganizationId == request.OrgId.Value && uo.IsActive)
                .Select(uo => uo.UserId)
                .ToListAsync(ct);
            paymentsQuery = paymentsQuery.Where(p => memberIds.Contains(p.UserId));
        }
        var payments = await paymentsQuery
            .Select(p => new PaymentRow(p.AmountSEK, p.CompletedAt))
            .ToListAsync(ct);

        // Corporate application count
        var totalApps = await _context.CorporateApplications
            .CountAsync(a => a.CreatedAt >= request.DateFrom && a.CreatedAt <= dateTo, ct);

        // Per-org summaries (only orgs with activity)
        var activeOrgIds = delegations.Select(d => d.OrganizationId).Distinct().ToList();
        var orgs = await _context.Organizations
            .Where(o => activeOrgIds.Contains(o.Id))
            .Select(o => new { o.Id, o.Name })
            .ToListAsync(ct);

        var orgSummaries = orgs.Select(o =>
        {
            var dels = delegations.Where(d => d.OrganizationId == o.Id).ToList();
            return new OrgSummaryDto(o.Id, o.Name, dels.Count, dels.Sum(d => d.CreditsDeducted), 0m);
        }).ToList();

        // Chart
        var chart = BuildChart(delegations, payments, request.DateFrom, request.DateTo, request.Granularity);

        return new OrgAnalyticsDto(
            orgSummaries,
            chart,
            delegations.Count,
            delegations.Sum(d => d.CreditsDeducted),
            payments.Sum(p => p.AmountSEK),
            totalApps
        );
    }

    private static List<AnalyticsDataPoint> BuildChart(
        List<DelegationRow> delegations,
        List<PaymentRow> payments,
        DateTime from, DateTime to, string granularity)
    {
        var points = new List<AnalyticsDataPoint>();
        var cursor = from.Date;

        while (cursor <= to.Date)
        {
            DateTime next;
            string label;

            switch (granularity.ToLowerInvariant())
            {
                case "weekly":
                    next = cursor.AddDays(7);
                    label = $"{cursor:dd.MM}–{next.AddDays(-1):dd.MM}";
                    break;
                case "monthly":
                    next = cursor.AddMonths(1);
                    label = cursor.ToString("MMM yyyy");
                    break;
                case "yearly":
                    next = cursor.AddYears(1);
                    label = cursor.Year.ToString();
                    break;
                default: // daily
                    next = cursor.AddDays(1);
                    label = cursor.ToString("dd.MM");
                    break;
            }

            var dels = delegations.Where(d => d.CreatedAt >= cursor && d.CreatedAt < next).ToList();
            var pays = payments.Where(p => p.CompletedAt.HasValue && p.CompletedAt.Value >= cursor && p.CompletedAt.Value < next).ToList();

            points.Add(new AnalyticsDataPoint(
                label,
                dels.Count,
                dels.Sum(d => d.CreditsDeducted),
                pays.Sum(p => p.AmountSEK)
            ));

            cursor = next;
        }

        return points;
    }
}

using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.CorporateApplications.DTOs;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.CorporateApplications.Queries;

public record GetCorporateApplicationsQuery(string? Status = null, int Page = 1, int PageSize = 20) : IRequest<object>;

public class GetCorporateApplicationsQueryHandler : IRequestHandler<GetCorporateApplicationsQuery, object>
{
    private readonly IApplicationDbContext _context;

    public GetCorporateApplicationsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<object> Handle(GetCorporateApplicationsQuery request, CancellationToken ct)
    {
        var query = _context.CorporateApplications.AsQueryable();

        if (!string.IsNullOrEmpty(request.Status) && Enum.TryParse<CorporateApplicationStatus>(request.Status, true, out var status))
            query = query.Where(a => a.Status == status);

        var total = await query.CountAsync(ct);

        var items = await query
            .OrderByDescending(a => a.CreatedAt)
            .Skip((request.Page - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(a => new CorporateApplicationDto(
                a.Id, a.CompanyName, a.OrgNumber, a.ContactName, a.ContactEmail,
                a.ContactPhone, a.DocumentPaths, a.DocumentsJson, a.Status.ToString(), a.ReviewNote,
                a.ReviewedAt, a.ReviewedByUser != null ? a.ReviewedByUser.FullName : null,
                a.ResubmitCount, a.PhoneVerified, a.CreatedAt))
            .ToListAsync(ct);

        return new { items, total, page = request.Page, pageSize = request.PageSize };
    }
}

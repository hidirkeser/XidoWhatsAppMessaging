using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Common.Models;
using Minion.Application.Features.Admin.DTOs;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Admin.Queries;

public record GetAuditLogsQuery(AuditLogFilterDto Filter) : IRequest<PaginatedList<AuditLogDto>>;

public class GetAuditLogsQueryHandler : IRequestHandler<GetAuditLogsQuery, PaginatedList<AuditLogDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAuditLogsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<PaginatedList<AuditLogDto>> Handle(GetAuditLogsQuery request, CancellationToken ct)
    {
        var f = request.Filter;
        var query = _context.AuditLogs
            .Include(a => a.Organization)
            .AsQueryable();

        if (!string.IsNullOrEmpty(f.Action) && Enum.TryParse<AuditAction>(f.Action, true, out var action))
            query = query.Where(a => a.Action == action);

        if (f.ActorUserId.HasValue)
            query = query.Where(a => a.ActorUserId == f.ActorUserId.Value);

        if (f.OrganizationId.HasValue)
            query = query.Where(a => a.OrganizationId == f.OrganizationId.Value);

        if (f.DateFrom.HasValue)
            query = query.Where(a => a.Timestamp >= f.DateFrom.Value);

        if (f.DateTo.HasValue)
            query = query.Where(a => a.Timestamp <= f.DateTo.Value);

        var projected = query
            .OrderByDescending(a => a.Timestamp)
            .Select(a => new AuditLogDto(
                a.Id, a.Timestamp, a.ActorName, a.Action.ToString(),
                a.TargetUserId, a.Organization != null ? a.Organization.Name : null,
                a.Details, a.IpAddress));

        return await PaginatedList<AuditLogDto>.CreateAsync(projected, f.Page, f.PageSize, ct);
    }
}

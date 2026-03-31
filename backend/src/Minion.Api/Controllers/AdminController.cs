using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Admin.Commands;
using Minion.Application.Features.Admin.DTOs;
using Minion.Application.Features.Admin.Queries;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Policy = "AdminOnly")]
public class AdminController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICreditService _creditService;
    private readonly IAuditLogService _audit;
    private readonly ICurrentUserService _currentUser;
    private readonly IApplicationDbContext _context;

    public AdminController(IMediator mediator, ICreditService creditService,
        IAuditLogService audit, ICurrentUserService currentUser, IApplicationDbContext context)
    {
        _mediator = mediator;
        _creditService = creditService;
        _audit = audit;
        _currentUser = currentUser;
        _context = context;
    }

    [HttpGet("dashboard")]
    public async Task<IActionResult> GetDashboard(CancellationToken ct)
        => Ok(await _mediator.Send(new GetDashboardStatsQuery(), ct));

    [HttpGet("organizations/analytics")]
    public async Task<IActionResult> GetOrgAnalytics(
        [FromQuery] Guid? orgId,
        [FromQuery] DateTime? dateFrom,
        [FromQuery] DateTime? dateTo,
        [FromQuery] string granularity = "daily",
        CancellationToken ct = default)
    {
        var from = dateFrom ?? DateTime.UtcNow.AddDays(-30);
        var to   = dateTo   ?? DateTime.UtcNow;
        return Ok(await _mediator.Send(new GetOrgAnalyticsQuery(orgId, from, to, granularity), ct));
    }

    [HttpGet("organizations/{orgId:guid}/credit-transactions")]
    public async Task<IActionResult> GetOrgCreditTransactions(Guid orgId, CancellationToken ct)
    {
        var memberIds = await _context.UserOrganizations
            .Where(uo => uo.OrganizationId == orgId && uo.IsActive)
            .Select(uo => uo.UserId)
            .ToListAsync(ct);

        var txs = await _context.CreditTransactions
            .Where(t => memberIds.Contains(t.UserId))
            .OrderByDescending(t => t.CreatedAt)
            .Take(200)
            .Select(t => new {
                t.Id, t.UserId, t.Amount, t.BalanceAfter,
                t.Description, t.CreatedAt,
                TransactionType = t.TransactionType.ToString()
            })
            .ToListAsync(ct);

        return Ok(txs);
    }

    [HttpGet("organizations/{orgId:guid}/payment-transactions")]
    public async Task<IActionResult> GetOrgPaymentTransactions(Guid orgId, CancellationToken ct)
    {
        var memberIds = await _context.UserOrganizations
            .Where(uo => uo.OrganizationId == orgId && uo.IsActive)
            .Select(uo => uo.UserId)
            .ToListAsync(ct);

        var txs = await _context.PaymentTransactions
            .Where(p => memberIds.Contains(p.UserId))
            .OrderByDescending(p => p.CreatedAt)
            .Take(200)
            .Select(p => new {
                p.Id, p.UserId, p.AmountSEK, p.CreditAmount,
                p.CompletedAt, p.CreatedAt,
                Status = p.Status.ToString(),
                Provider = p.Provider.ToString()
            })
            .ToListAsync(ct);

        return Ok(txs);
    }

    [HttpGet("audit-logs")]
    public async Task<IActionResult> GetAuditLogs(
        [FromQuery] string? action, [FromQuery] Guid? actorUserId,
        [FromQuery] Guid? organizationId, [FromQuery] DateTime? dateFrom,
        [FromQuery] DateTime? dateTo, [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50, CancellationToken ct = default)
    {
        var filter = new AuditLogFilterDto(action, actorUserId, organizationId, dateFrom, dateTo, page, pageSize);
        return Ok(await _mediator.Send(new GetAuditLogsQuery(filter), ct));
    }

    // ── Bildirim Ayarları ────────────────────────────────────────────────────

    [HttpGet("notification-settings")]
    public async Task<IActionResult> GetNotificationSettings(CancellationToken ct)
        => Ok(await _mediator.Send(new GetNotificationSettingsQuery(), ct));

    [HttpPut("notification-settings")]
    public async Task<IActionResult> UpdateNotificationSettings(
        [FromBody] UpdateNotificationSettingsCommand command, CancellationToken ct)
    {
        await _mediator.Send(command, ct);
        return NoContent();
    }

    [HttpPost("users/{userId:guid}/credits")]
    public async Task<IActionResult> AdjustCredits(Guid userId, [FromBody] ManualCreditAdjustRequest request, CancellationToken ct)
    {
        var adminId = _currentUser.UserId ?? throw new UnauthorizedAccessException();
        await _creditService.ManualAdjustAsync(userId, request.Amount, request.Description, adminId, ct);
        await _audit.LogAsync(
            request.Amount >= 0 ? AuditAction.CreditManualAdd : AuditAction.CreditManualRemove,
            targetUserId: userId,
            details: new { request.Amount, request.Description }, ct: ct);
        var balance = await _creditService.GetBalanceAsync(userId, ct);
        return Ok(new { balance });
    }
}

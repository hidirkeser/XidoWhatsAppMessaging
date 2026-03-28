using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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

    public AdminController(IMediator mediator, ICreditService creditService,
        IAuditLogService audit, ICurrentUserService currentUser)
    {
        _mediator = mediator;
        _creditService = creditService;
        _audit = audit;
        _currentUser = currentUser;
    }

    [HttpGet("dashboard")]
    public async Task<IActionResult> GetDashboard(CancellationToken ct)
        => Ok(await _mediator.Send(new GetDashboardStatsQuery(), ct));

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

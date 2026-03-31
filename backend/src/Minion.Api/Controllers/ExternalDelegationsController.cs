using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Minion.Infrastructure.Persistence;

namespace Minion.Api.Controllers;

/// <summary>
/// Machine-to-machine API for organizations.
/// Auth: X-Api-Key + X-Api-Secret headers (set by ApiKeyAuthMiddleware).
/// </summary>
[ApiController]
[Route("api/external/delegations")]
public class ExternalDelegationsController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    public ExternalDelegationsController(ApplicationDbContext db) => _db = db;

    private Guid? OrgId => HttpContext.Items["OrganizationId"] as Guid?;

    [HttpGet]
    public async Task<IActionResult> GetDelegations(
        [FromQuery] string? status,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50,
        CancellationToken ct = default)
    {
        if (OrgId == null) return Unauthorized(new { error = "Invalid or missing API key." });

        var query = _db.Delegations
            .Where(d => d.OrganizationId == OrgId);

        if (!string.IsNullOrEmpty(status) &&
            Enum.TryParse<Minion.Domain.Enums.DelegationStatus>(status, true, out var s))
            query = query.Where(d => d.Status == s);
        else
            query = query.Where(d => d.Status == Minion.Domain.Enums.DelegationStatus.Active);

        var total = await query.CountAsync(ct);

        var items = await query
            .OrderByDescending(d => d.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(d => new
            {
                d.Id,
                d.VerificationCode,
                d.Status,
                GrantorName    = d.GrantorUser.FullName,
                DelegateName   = d.DelegateUser.FullName,
                d.ValidFrom,
                d.ValidTo,
                d.AcceptedAt,
                d.DelegateSignature,
                Operations = d.DelegationOperations.Select(op => op.OperationType.Name).ToList(),
            })
            .ToListAsync(ct);

        return Ok(new { items, total, page, pageSize });
    }

    [HttpGet("{verificationCode}")]
    public async Task<IActionResult> GetByCode(string verificationCode, CancellationToken ct)
    {
        if (OrgId == null) return Unauthorized(new { error = "Invalid or missing API key." });

        var d = await _db.Delegations
            .Where(d => d.VerificationCode == verificationCode && d.OrganizationId == OrgId)
            .Select(d => new
            {
                d.Id,
                d.VerificationCode,
                d.Status,
                GrantorName    = d.GrantorUser.FullName,
                DelegateName   = d.DelegateUser.FullName,
                d.ValidFrom,
                d.ValidTo,
                d.AcceptedAt,
                d.RejectedAt,
                d.RejectionNote,
                d.RevokedAt,
                d.DelegateSignature,
                Operations = d.DelegationOperations.Select(op => op.OperationType.Name).ToList(),
            })
            .FirstOrDefaultAsync(ct);

        if (d == null) return NotFound(new { error = "Delegation not found." });
        return Ok(d);
    }
}

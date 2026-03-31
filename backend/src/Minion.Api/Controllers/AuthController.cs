using System.Collections.Concurrent;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[EnableRateLimiting("auth")]
public class AuthController : ControllerBase
{
    private readonly IBankIdService _bankIdService;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IApplicationDbContext _context;
    private readonly IAuditLogService _auditLogService;

    // In-memory store for active auth sessions (production: use Redis/DB)
    private static readonly ConcurrentDictionary<string, AuthSession> _sessions = new();

    public AuthController(
        IBankIdService bankIdService,
        IJwtTokenService jwtTokenService,
        IApplicationDbContext context,
        IAuditLogService auditLogService)
    {
        _bankIdService = bankIdService;
        _jwtTokenService = jwtTokenService;
        _context = context;
        _auditLogService = auditLogService;
    }

    [HttpPost("init")]
    public async Task<IActionResult> InitAuth(CancellationToken ct)
    {
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        var result = await _bankIdService.InitAuthAsync(ip, ct);

        _sessions[result.OrderRef] = new AuthSession(
            result.OrderRef,
            result.QrStartToken,
            result.QrStartSecret,
            DateTime.UtcNow);

        return Ok(new
        {
            result.OrderRef,
            result.AutoStartToken,
            qrData = _bankIdService.GenerateQrCode(result.QrStartToken, result.QrStartSecret, 0)
        });
    }

    [HttpPost("collect")]
    [DisableRateLimiting]
    public async Task<IActionResult> Collect([FromBody] CollectRequest request, CancellationToken ct)
    {
        var result = await _bankIdService.CollectAsync(request.OrderRef, ct);

        if (result.Status == "complete" && result.CompletionData != null)
        {
            _sessions.TryRemove(request.OrderRef, out _);

            var user = await GetOrCreateUserAsync(result.CompletionData, ct);

            var accessToken = _jwtTokenService.GenerateAccessToken(user);
            var refreshToken = _jwtTokenService.GenerateRefreshToken();

            user.LastLoginAt = DateTime.UtcNow;
            await _context.SaveChangesAsync(ct);

            await _auditLogService.LogAsync(AuditAction.Login, user.Id, user.FullName, ct: ct);

            return Ok(new
            {
                status = "complete",
                accessToken,
                refreshToken,
                user = new { user.Id, user.FirstName, user.LastName, user.PersonalNumber, user.Email, user.Phone, user.IsAdmin, user.GdprConsentAcceptedAt }
            });
        }

        return Ok(new
        {
            result.Status,
            result.HintCode
        });
    }

    [HttpGet("qr/{orderRef}")]
    [DisableRateLimiting]
    public IActionResult GetQrCode(string orderRef)
    {
        if (!_sessions.TryGetValue(orderRef, out var session))
            return NotFound(new { error = "Session not found" });

        var elapsed = (int)(DateTime.UtcNow - session.StartedAt).TotalSeconds;
        var qrData = _bankIdService.GenerateQrCode(session.QrStartToken, session.QrStartSecret, elapsed);

        return Ok(new { qrData });
    }

    [HttpPost("cancel")]
    public async Task<IActionResult> Cancel([FromBody] CancelRequest request, CancellationToken ct)
    {
        await _bankIdService.CancelAsync(request.OrderRef, ct);
        _sessions.TryRemove(request.OrderRef, out _);
        return Ok();
    }

    [HttpPost("sign/init")]
    public async Task<IActionResult> InitSign([FromBody] SignInitRequest request, CancellationToken ct)
    {
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        var result = await _bankIdService.InitSignAsync(ip, request.UserVisibleData, ct);

        _sessions[result.OrderRef] = new AuthSession(
            result.OrderRef,
            result.QrStartToken,
            result.QrStartSecret,
            DateTime.UtcNow);

        return Ok(new
        {
            result.OrderRef,
            result.AutoStartToken,
            qrData = _bankIdService.GenerateQrCode(result.QrStartToken, result.QrStartSecret, 0)
        });
    }

    [HttpPost("sign/collect")]
    [DisableRateLimiting]
    public async Task<IActionResult> SignCollect([FromBody] CollectRequest request, CancellationToken ct)
    {
        var result = await _bankIdService.CollectAsync(request.OrderRef, ct);

        if (result.Status == "complete")
        {
            _sessions.TryRemove(request.OrderRef, out _);
            return Ok(new
            {
                status = "complete",
                signature = result.CompletionData?.Signature,
                personalNumber = result.CompletionData?.PersonalNumber
            });
        }

        return Ok(new { result.Status, result.HintCode });
    }

    private async Task<User> GetOrCreateUserAsync(BankIdCompletionData data, CancellationToken ct)
    {
        var user = await _context.Users.FirstOrDefaultAsync(
            u => u.PersonalNumber == data.PersonalNumber, ct);

        if (user == null)
        {
            user = new User
            {
                Id = Guid.NewGuid(),
                PersonalNumber = data.PersonalNumber,
                FirstName = data.GivenName,
                LastName = data.Surname,
                IsActive = true
            };
            _context.Users.Add(user);

            var isDev = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")
                ?.Equals("Development", StringComparison.OrdinalIgnoreCase) ?? false;

            _context.UserCredits.Add(new UserCredit
            {
                Id = Guid.NewGuid(),
                UserId = user.Id,
                Balance = isDev ? 100 : 0
            });

            if (isDev)
            {
                var adminId = Guid.Parse("00000000-0000-0000-0000-000000000001");
                var orgs = await _context.Organizations.Where(o => o.IsActive).ToListAsync(ct);
                foreach (var org in orgs)
                    _context.UserOrganizations.Add(new UserOrganization
                    {
                        Id = Guid.NewGuid(),
                        UserId = user.Id,
                        OrganizationId = org.Id,
                        Role = "Admin",
                        AssignedByUserId = adminId
                    });
            }

            await _context.SaveChangesAsync(ct);
        }

        if (user != null)
        {
            var isDev = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")
                ?.Equals("Development", StringComparison.OrdinalIgnoreCase) ?? false;

            if (isDev)
            {
                var hasOrgs = await _context.UserOrganizations.AnyAsync(uo => uo.UserId == user.Id, ct);
                if (!hasOrgs)
                {
                    var adminId = Guid.Parse("00000000-0000-0000-0000-000000000001");
                    var orgs = await _context.Organizations.Where(o => o.IsActive).ToListAsync(ct);
                    foreach (var org in orgs)
                        _context.UserOrganizations.Add(new UserOrganization
                        {
                            Id = Guid.NewGuid(),
                            UserId = user.Id,
                            OrganizationId = org.Id,
                            Role = "Admin",
                            AssignedByUserId = adminId
                        });

                    var credits = await _context.UserCredits.FirstOrDefaultAsync(uc => uc.UserId == user.Id, ct);
                    if (credits != null && credits.Balance == 0)
                        credits.Balance = 100;

                    await _context.SaveChangesAsync(ct);
                }
            }
        }

        return user!;
    }

    public record CollectRequest(string OrderRef);
    public record CancelRequest(string OrderRef);
    public record SignInitRequest(string UserVisibleData);

    private record AuthSession(
        string OrderRef,
        string QrStartToken,
        string QrStartSecret,
        DateTime StartedAt);
}

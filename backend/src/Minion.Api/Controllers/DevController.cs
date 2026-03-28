using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Interfaces;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[AllowAnonymous]
public class DevController : ControllerBase
{
    private readonly IApplicationDbContext _context;
    private readonly IJwtTokenService _jwtTokenService;

    public DevController(IApplicationDbContext context, IJwtTokenService jwtTokenService)
    {
        _context = context;
        _jwtTokenService = jwtTokenService;
    }

    [HttpPost("test-login/{personalNumber}")]
    public async Task<IActionResult> TestLogin(string personalNumber, CancellationToken ct)
    {
        if (!Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")?.Equals("Development", StringComparison.OrdinalIgnoreCase) ?? true)
            return NotFound();

        var user = await _context.Users.FirstOrDefaultAsync(u => u.PersonalNumber == personalNumber, ct);
        if (user == null) return NotFound(new { error = "User not found" });

        var accessToken = _jwtTokenService.GenerateAccessToken(user);
        return Ok(new
        {
            accessToken,
            user = new { user.Id, user.FirstName, user.LastName, user.PersonalNumber, user.Email, user.IsAdmin }
        });
    }

    [HttpGet("seed-data")]
    public async Task<IActionResult> GetSeedData(CancellationToken ct)
    {
        var users = await _context.Users.Select(u => new { u.Id, u.PersonalNumber, u.FirstName, u.LastName, u.IsAdmin }).ToListAsync(ct);
        var orgs = await _context.Organizations.Select(o => new { o.Id, o.Name, o.OrgNumber }).ToListAsync(ct);
        var packages = await _context.CreditPackages.Select(p => new { p.Id, p.Name, p.CreditAmount, p.PriceSEK }).ToListAsync(ct);

        return Ok(new { users, organizations = orgs, creditPackages = packages });
    }
}

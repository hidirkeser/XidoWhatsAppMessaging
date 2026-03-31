using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Entities;
using Minion.Domain.Interfaces;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[AllowAnonymous]
public class DevController : ControllerBase
{
    private readonly IApplicationDbContext _context;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly ICurrentUserService _currentUser;

    public DevController(IApplicationDbContext context, IJwtTokenService jwtTokenService, ICurrentUserService currentUser)
    {
        _context = context;
        _jwtTokenService = jwtTokenService;
        _currentUser = currentUser;
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

    [HttpPost("setup-current-user")]
    [Authorize]
    public async Task<IActionResult> SetupCurrentUser(CancellationToken ct)
    {
        if (!Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")?.Equals("Development", StringComparison.OrdinalIgnoreCase) ?? true)
            return NotFound();

        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();
        var adminId = Guid.Parse("00000000-0000-0000-0000-000000000001");

        var orgs = await _context.Organizations.Where(o => o.IsActive).ToListAsync(ct);
        foreach (var org in orgs)
        {
            var exists = await _context.UserOrganizations.AnyAsync(uo => uo.UserId == userId && uo.OrganizationId == org.Id, ct);
            if (!exists)
                _context.UserOrganizations.Add(new UserOrganization { Id = Guid.NewGuid(), UserId = userId, OrganizationId = org.Id, Role = "Admin", AssignedByUserId = adminId });
        }

        var credits = await _context.UserCredits.FirstOrDefaultAsync(uc => uc.UserId == userId, ct);
        if (credits == null)
            _context.UserCredits.Add(new UserCredit { Id = Guid.NewGuid(), UserId = userId, Balance = 100 });
        else if (credits.Balance == 0)
            credits.Balance = 100;

        await _context.SaveChangesAsync(ct);
        return Ok(new { message = "User setup complete", orgsAdded = orgs.Count });
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

using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.Organizations.Queries;
using Minion.Application.Features.Users.Commands;
using Minion.Application.Features.Users.DTOs;
using Minion.Application.Features.Users.Queries;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly IMediator _mediator;

    public UsersController(IMediator mediator) => _mediator = mediator;

    [HttpGet("me")]
    public async Task<IActionResult> GetCurrentUser(CancellationToken ct)
        => Ok(await _mediator.Send(new GetCurrentUserQuery(), ct));

    [HttpPut("me")]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request, CancellationToken ct)
        => Ok(await _mediator.Send(new UpdateProfileCommand(request.Email, request.Phone), ct));

    [HttpGet("search")]
    public async Task<IActionResult> SearchUsers([FromQuery] string q, CancellationToken ct)
        => Ok(await _mediator.Send(new SearchUsersQuery(q), ct));

    [HttpPost("device-token")]
    public async Task<IActionResult> RegisterDeviceToken([FromBody] RegisterDeviceTokenCommand command, CancellationToken ct)
    {
        await _mediator.Send(command, ct);
        return Ok();
    }

    [HttpGet("me/organizations")]
    public async Task<IActionResult> GetMyOrganizations(CancellationToken ct)
        => Ok(await _mediator.Send(new GetMyOrganizationsQuery(), ct));

    [HttpGet("me/export")]
    public async Task<IActionResult> ExportData(CancellationToken ct)
        => Ok(await _mediator.Send(new ExportUserDataCommand(), ct));

    [HttpDelete("me")]
    public async Task<IActionResult> DeleteData(CancellationToken ct)
    {
        await _mediator.Send(new DeleteUserDataCommand(), ct);
        return NoContent();
    }

    [HttpPost("me/consent")]
    public async Task<IActionResult> AcceptConsent([FromBody] AcceptConsentRequest request, CancellationToken ct)
    {
        await _mediator.Send(new AcceptConsentCommand(request.MarketingConsent), ct);
        return Ok();
    }

    public record AcceptConsentRequest(bool MarketingConsent);
}

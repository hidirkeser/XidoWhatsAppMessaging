using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.Organizations.Commands;
using Minion.Application.Features.Organizations.DTOs;
using Minion.Application.Features.Organizations.Queries;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class OrganizationsController : ControllerBase
{
    private readonly IMediator _mediator;

    public OrganizationsController(IMediator mediator) => _mediator = mediator;

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct)
        => Ok(await _mediator.Send(new GetOrganizationsQuery(), ct));

    [HttpPost]
    [Authorize(Policy = "AdminOnly")]
    public async Task<IActionResult> Create([FromBody] CreateOrganizationRequest request, CancellationToken ct)
    {
        var command = new CreateOrganizationCommand(
            request.Name, request.OrgNumber, request.Address, request.City,
            request.PostalCode, request.ContactEmail, request.ContactPhone);
        var result = await _mediator.Send(command, ct);
        return CreatedAtAction(nameof(GetAll), new { id = result.Id }, result);
    }

    [HttpPut("{id:guid}")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateOrganizationRequest request, CancellationToken ct)
    {
        var command = new UpdateOrganizationCommand(id, request.Name, request.Address,
            request.City, request.PostalCode, request.ContactEmail, request.ContactPhone);
        return Ok(await _mediator.Send(command, ct));
    }

    [HttpDelete("{id:guid}")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        await _mediator.Send(new DeleteOrganizationCommand(id), ct);
        return NoContent();
    }

    [HttpPost("{id:guid}/users")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<IActionResult> AssignUser(Guid id, [FromBody] AssignUserToOrgRequest request, CancellationToken ct)
    {
        await _mediator.Send(new AssignUserToOrgCommand(id, request.UserId, request.Role), ct);
        return Ok();
    }

    [HttpDelete("{id:guid}/users/{userId:guid}")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<IActionResult> RemoveUser(Guid id, Guid userId, CancellationToken ct)
    {
        await _mediator.Send(new RemoveUserFromOrgCommand(id, userId), ct);
        return NoContent();
    }
}

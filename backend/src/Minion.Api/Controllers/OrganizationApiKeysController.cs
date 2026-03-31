using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.OrganizationApiKeys.Commands;
using Minion.Application.Features.OrganizationApiKeys.DTOs;
using Minion.Application.Features.OrganizationApiKeys.Queries;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/organizations/{orgId:guid}/api-keys")]
[Authorize]
public class OrganizationApiKeysController : ControllerBase
{
    private readonly IMediator _mediator;
    public OrganizationApiKeysController(IMediator mediator) => _mediator = mediator;

    [HttpGet]
    public async Task<IActionResult> GetAll(Guid orgId, CancellationToken ct)
        => Ok(await _mediator.Send(new GetApiKeysQuery(orgId), ct));

    [HttpPost]
    public async Task<IActionResult> Create(Guid orgId, [FromBody] CreateApiKeyRequest request, CancellationToken ct)
    {
        var result = await _mediator.Send(new CreateApiKeyCommand(orgId, request.Name), ct);
        return Created("", result);
    }

    [HttpDelete("{keyId:guid}")]
    public async Task<IActionResult> Revoke(Guid orgId, Guid keyId, CancellationToken ct)
    {
        await _mediator.Send(new RevokeApiKeyCommand(orgId, keyId), ct);
        return NoContent();
    }
}

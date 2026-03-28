using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.OperationTypes.Commands;
using Minion.Application.Features.OperationTypes.DTOs;
using Minion.Application.Features.OperationTypes.Queries;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/organizations/{orgId:guid}/operation-types")]
[Authorize]
public class OperationTypesController : ControllerBase
{
    private readonly IMediator _mediator;

    public OperationTypesController(IMediator mediator) => _mediator = mediator;

    [HttpGet]
    public async Task<IActionResult> GetByOrg(Guid orgId, CancellationToken ct)
        => Ok(await _mediator.Send(new GetOperationTypesByOrgQuery(orgId), ct));

    [HttpPost]
    [Authorize(Policy = "AdminOnly")]
    public async Task<IActionResult> Create(Guid orgId, [FromBody] CreateOperationTypeRequest request, CancellationToken ct)
    {
        var command = new CreateOperationTypeCommand(orgId, request.Name, request.Description,
            request.Icon, request.CreditCost, request.SortOrder);
        return Created("", await _mediator.Send(command, ct));
    }

    [HttpPut("{id:guid}")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateOperationTypeRequest request, CancellationToken ct)
    {
        var command = new UpdateOperationTypeCommand(id, request.Name, request.Description,
            request.Icon, request.CreditCost, request.SortOrder);
        return Ok(await _mediator.Send(command, ct));
    }

    [HttpPatch("{id:guid}/toggle")]
    [Authorize(Policy = "AdminOnly")]
    public async Task<IActionResult> Toggle(Guid id, CancellationToken ct)
    {
        await _mediator.Send(new ToggleOperationTypeCommand(id), ct);
        return Ok();
    }
}

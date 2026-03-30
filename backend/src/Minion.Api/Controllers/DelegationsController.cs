using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.Delegations.Commands;
using Minion.Application.Features.Delegations.DTOs;
using Minion.Application.Features.Delegations.Queries;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class DelegationsController : ControllerBase
{
    private readonly IMediator _mediator;

    public DelegationsController(IMediator mediator) => _mediator = mediator;

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateDelegationRequest request, CancellationToken ct)
    {
        var command = new CreateDelegationCommand(
            request.DelegateUserId, request.OrganizationId, request.OperationTypeIds,
            request.DurationType, request.DurationValue,
            request.DateFrom, request.DateTo, request.Notes,
            request.BankIdOrderRef, request.BankIdSignature);
        return Created("", await _mediator.Send(command, ct));
    }

    [HttpGet("granted")]
    public async Task<IActionResult> GetGranted(
        [FromQuery] string? status, [FromQuery] Guid? organizationId,
        [FromQuery] DateTime? dateFrom, [FromQuery] DateTime? dateTo,
        [FromQuery] string? search, [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20, CancellationToken ct = default)
    {
        var filter = new DelegationFilterDto(status, organizationId, dateFrom, dateTo, search, page, pageSize);
        return Ok(await _mediator.Send(new GetGrantedDelegationsQuery(filter), ct));
    }

    [HttpGet("received")]
    public async Task<IActionResult> GetReceived(
        [FromQuery] string? status, [FromQuery] Guid? organizationId,
        [FromQuery] DateTime? dateFrom, [FromQuery] DateTime? dateTo,
        [FromQuery] string? search, [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20, CancellationToken ct = default)
    {
        var filter = new DelegationFilterDto(status, organizationId, dateFrom, dateTo, search, page, pageSize);
        return Ok(await _mediator.Send(new GetReceivedDelegationsQuery(filter), ct));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken ct)
        => Ok(await _mediator.Send(new GetDelegationByIdQuery(id), ct));

    [HttpPost("{id:guid}/accept")]
    public async Task<IActionResult> Accept(Guid id, [FromBody] AcceptDelegationRequest? request, CancellationToken ct)
    {
        await _mediator.Send(new AcceptDelegationCommand(id, request?.DelegateSignOrderRef, request?.DelegateSignature), ct);
        return Ok();
    }

    public record AcceptDelegationRequest(string? DelegateSignOrderRef, string? DelegateSignature);

    [HttpPost("{id:guid}/reject")]
    public async Task<IActionResult> Reject(Guid id, [FromBody] RejectDelegationRequest? request, CancellationToken ct)
    {
        await _mediator.Send(new RejectDelegationCommand(id, request?.Note), ct);
        return Ok();
    }

    public record RejectDelegationRequest(string? Note);

    [HttpPost("{id:guid}/revoke")]
    public async Task<IActionResult> Revoke(Guid id, CancellationToken ct)
    {
        await _mediator.Send(new RevokeDelegationCommand(id), ct);
        return Ok();
    }
}

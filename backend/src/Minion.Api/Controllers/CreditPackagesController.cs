using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.Credits.Commands;
using Minion.Application.Features.Credits.DTOs;
using Minion.Application.Features.Credits.Queries;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/admin/credit-packages")]
[Authorize(Policy = "AdminOnly")]
public class CreditPackagesController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IAuditLogService _audit;

    public CreditPackagesController(IMediator mediator, IAuditLogService audit)
    {
        _mediator = mediator;
        _audit = audit;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct)
        => Ok(await _mediator.Send(new GetAllCreditPackagesQuery(), ct));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateCreditPackageRequest request, CancellationToken ct)
    {
        var result = await _mediator.Send(new CreateCreditPackageCommand(
            request.Name, request.NameSv, request.CreditAmount, request.PriceSEK,
            request.Description, request.DescriptionSv, request.Badge, request.BadgeSv,
            request.SortOrder), ct);

        await _audit.LogAsync(AuditAction.CreditPackageCreate,
            details: new { result.Id, result.Name }, ct: ct);

        return Created("", result);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateCreditPackageRequest request, CancellationToken ct)
    {
        var result = await _mediator.Send(new UpdateCreditPackageCommand(
            id, request.Name, request.NameSv, request.CreditAmount, request.PriceSEK,
            request.Description, request.DescriptionSv, request.Badge, request.BadgeSv,
            request.SortOrder), ct);

        await _audit.LogAsync(AuditAction.CreditPackageUpdate,
            details: new { result.Id, result.Name }, ct: ct);

        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        await _mediator.Send(new DeleteCreditPackageCommand(id), ct);
        await _audit.LogAsync(AuditAction.CreditPackageDelete, details: new { CreditPackageId = id }, ct: ct);
        return NoContent();
    }

    [HttpPatch("{id:guid}/toggle")]
    public async Task<IActionResult> Toggle(Guid id, CancellationToken ct)
    {
        await _mediator.Send(new ToggleCreditPackageCommand(id), ct);
        return Ok();
    }
}

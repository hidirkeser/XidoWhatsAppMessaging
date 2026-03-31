using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.WebProducts.Commands;
using Minion.Application.Features.WebProducts.DTOs;
using Minion.Application.Features.WebProducts.Queries;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/admin/web-products")]
[Authorize(Policy = "AdminOnly")]
public class AdminWebProductsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IAuditLogService _audit;

    public AdminWebProductsController(IMediator mediator, IAuditLogService audit)
    {
        _mediator = mediator;
        _audit = audit;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct)
        => Ok(await _mediator.Send(new GetAllWebProductsQuery(), ct));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateWebProductRequest request, CancellationToken ct)
    {
        var result = await _mediator.Send(new CreateWebProductCommand(
            request.Slug, request.Icon, request.Color,
            request.NameEn, request.DescriptionEn, request.FeaturesEn,
            request.NameSv, request.DescriptionSv, request.FeaturesSv,
            request.SortOrder), ct);

        await _audit.LogAsync(AuditAction.WebProductCreate,
            details: new { result.Id, result.NameEn }, ct: ct);

        return Created("", result);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateWebProductRequest request, CancellationToken ct)
    {
        var result = await _mediator.Send(new UpdateWebProductCommand(
            id, request.Slug, request.Icon, request.Color,
            request.NameEn, request.DescriptionEn, request.FeaturesEn,
            request.NameSv, request.DescriptionSv, request.FeaturesSv,
            request.SortOrder), ct);

        await _audit.LogAsync(AuditAction.WebProductUpdate,
            details: new { result.Id, result.NameEn }, ct: ct);

        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        await _mediator.Send(new DeleteWebProductCommand(id), ct);
        await _audit.LogAsync(AuditAction.WebProductDelete, details: new { WebProductId = id }, ct: ct);
        return NoContent();
    }

    [HttpPatch("{id:guid}/toggle")]
    public async Task<IActionResult> Toggle(Guid id, CancellationToken ct)
    {
        await _mediator.Send(new ToggleWebProductCommand(id), ct);
        return Ok();
    }
}

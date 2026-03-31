using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.Products.Commands;
using Minion.Application.Features.Products.DTOs;
using Minion.Application.Features.Products.Queries;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IMediator _mediator;

    public ProductsController(IMediator mediator) => _mediator = mediator;

    [HttpGet]
    [AllowAnonymous]
    public async Task<IActionResult> GetProducts([FromQuery] string? type, CancellationToken ct)
        => Ok(await _mediator.Send(new GetProductsQuery(type), ct));

    [HttpGet("{id:guid}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetProduct(Guid id, CancellationToken ct)
    {
        var products = await _mediator.Send(new GetProductsQuery(), ct);
        var product = products.FirstOrDefault(p => p.Id == id);
        return product != null ? Ok(product) : NotFound();
    }
}

[ApiController]
[Route("api/admin/products")]
[Authorize(Policy = "AdminOnly")]
public class AdminProductsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IAuditLogService _audit;

    public AdminProductsController(IMediator mediator, IAuditLogService audit)
    {
        _mediator = mediator;
        _audit = audit;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct)
        => Ok(await _mediator.Send(new GetAllProductsQuery(), ct));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateProductRequest request, CancellationToken ct)
    {
        var result = await _mediator.Send(new CreateProductCommand(
            request.Name, request.Description, request.Type,
            request.MonthlyQuota, request.PriceSEK, request.Features, request.SortOrder), ct);

        await _audit.LogAsync(AuditAction.ProductCreate,
            details: new { result.Id, result.Name, result.Type }, ct: ct);

        return Created("", result);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateProductRequest request, CancellationToken ct)
    {
        var result = await _mediator.Send(new UpdateProductCommand(
            id, request.Name, request.Description, request.Type,
            request.MonthlyQuota, request.PriceSEK, request.Features, request.SortOrder), ct);

        await _audit.LogAsync(AuditAction.ProductUpdate,
            details: new { result.Id, result.Name }, ct: ct);

        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        await _mediator.Send(new DeleteProductCommand(id), ct);
        await _audit.LogAsync(AuditAction.ProductDelete, details: new { ProductId = id }, ct: ct);
        return NoContent();
    }

    [HttpPatch("{id:guid}/toggle")]
    public async Task<IActionResult> Toggle(Guid id, CancellationToken ct)
    {
        await _mediator.Send(new ToggleProductCommand(id), ct);
        return Ok();
    }
}

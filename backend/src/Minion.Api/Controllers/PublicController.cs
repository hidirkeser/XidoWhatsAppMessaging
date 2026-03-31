using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.Credits.Queries;
using Minion.Application.Features.Products.Queries;
using Minion.Application.Features.WebProducts.Queries;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/public")]
[AllowAnonymous]
public class PublicController : ControllerBase
{
    private readonly IMediator _mediator;

    public PublicController(IMediator mediator) => _mediator = mediator;

    [HttpGet("web-products")]
    public async Task<IActionResult> GetWebProducts([FromQuery] string locale = "en", CancellationToken ct = default)
        => Ok(await _mediator.Send(new GetPublicWebProductsQuery(locale), ct));

    [HttpGet("products")]
    public async Task<IActionResult> GetProducts([FromQuery] string locale = "en", [FromQuery] string? type = null, CancellationToken ct = default)
        => Ok(await _mediator.Send(new GetPublicProductsQuery(locale, type), ct));

    [HttpGet("credit-packages")]
    public async Task<IActionResult> GetCreditPackages([FromQuery] string locale = "en", CancellationToken ct = default)
        => Ok(await _mediator.Send(new GetPublicCreditPackagesQuery(locale), ct));
}

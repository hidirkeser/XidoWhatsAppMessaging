using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.Subscriptions.Commands;
using Minion.Application.Features.Subscriptions.DTOs;
using Minion.Application.Features.Subscriptions.Queries;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SubscriptionsController : ControllerBase
{
    private readonly IMediator _mediator;

    public SubscriptionsController(IMediator mediator) => _mediator = mediator;

    [HttpGet("current")]
    public async Task<IActionResult> GetCurrent(CancellationToken ct)
        => Ok(await _mediator.Send(new GetCurrentSubscriptionQuery(), ct));

    [HttpGet("quota")]
    public async Task<IActionResult> GetQuota(CancellationToken ct)
        => Ok(await _mediator.Send(new GetQuotaStatusQuery(), ct));

    [HttpPost("purchase")]
    public async Task<IActionResult> Purchase([FromBody] PurchaseSubscriptionRequest request, CancellationToken ct)
    {
        var baseUrl = $"{Request.Scheme}://{Request.Host}";
        var returnUrl = $"{baseUrl}/payment/success";

        var result = await _mediator.Send(new PurchaseSubscriptionCommand(
            request.ProductId, request.Provider, request.PayerPhone, baseUrl, returnUrl), ct);

        return Ok(result);
    }
}

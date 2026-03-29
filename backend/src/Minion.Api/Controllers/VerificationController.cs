using MediatR;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.Delegations.Queries;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/verify")]
public class VerificationController : ControllerBase
{
    private readonly IMediator _mediator;

    public VerificationController(IMediator mediator)
    {
        _mediator = mediator;
    }

    /// <summary>
    /// Public endpoint — no authentication required.
    /// Used by third parties to verify a delegation is active.
    /// </summary>
    [HttpGet("{code}")]
    public async Task<IActionResult> Verify(string code, CancellationToken ct)
    {
        var result = await _mediator.Send(new GetDelegationByVerificationCodeQuery(code), ct);
        return Ok(result);
    }
}

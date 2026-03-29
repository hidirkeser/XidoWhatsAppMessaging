using MediatR;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.Delegations.Commands;
using Minion.Application.Features.Delegations.Queries;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/verify")]
public class VerificationController : ControllerBase
{
    private readonly IMediator _mediator;
    public VerificationController(IMediator mediator) => _mediator = mediator;

    /// <summary>Public — no auth required. Returns delegation info.</summary>
    [HttpGet("{code}")]
    public async Task<IActionResult> GetDelegation(string code, CancellationToken ct)
    {
        var result = await _mediator.Send(new GetDelegationByVerificationCodeQuery(code), ct);
        return Ok(result);
    }

    /// <summary>Public — initiate BankID sign for verification.</summary>
    [HttpPost("{code}/init")]
    public async Task<IActionResult> InitVerification(string code, CancellationToken ct)
    {
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        var result = await _mediator.Send(new InitDelegationVerificationCommand(code, ip), ct);
        return Ok(result);
    }

    /// <summary>Public — collect BankID result and save verification log.</summary>
    [HttpPost("{code}/collect")]
    public async Task<IActionResult> CollectVerification(
        string code,
        [FromBody] CollectVerificationRequest request,
        CancellationToken ct)
    {
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        var channel = request.Channel ?? "web";
        var result = await _mediator.Send(
            new CollectDelegationVerificationCommand(code, request.OrderRef, channel, ip), ct);
        return Ok(result);
    }
}

public record CollectVerificationRequest(string OrderRef, string? Channel);

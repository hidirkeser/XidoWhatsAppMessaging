using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.Credits.Commands;
using Minion.Application.Features.Credits.DTOs;
using Minion.Application.Features.Credits.Queries;
using System.Text.Json;
using Minion.Domain.Interfaces;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CreditsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IPaymentServiceFactory _paymentFactory;

    public CreditsController(IMediator mediator, IPaymentServiceFactory paymentFactory)
    {
        _mediator = mediator;
        _paymentFactory = paymentFactory;
    }

    [HttpGet("balance")]
    public async Task<IActionResult> GetBalance(CancellationToken ct)
        => Ok(await _mediator.Send(new GetCreditBalanceQuery(), ct));

    [HttpGet("history")]
    public async Task<IActionResult> GetHistory([FromQuery] int page = 1, [FromQuery] int pageSize = 20, CancellationToken ct = default)
        => Ok(await _mediator.Send(new GetCreditHistoryQuery(page, pageSize), ct));

    [HttpGet("packages")]
    public async Task<IActionResult> GetPackages(CancellationToken ct)
        => Ok(await _mediator.Send(new GetCreditPackagesQuery(), ct));

    [HttpPost("purchase")]
    public async Task<IActionResult> Purchase([FromBody] PurchaseCreditsRequest request, CancellationToken ct)
    {
        var baseUrl = $"{Request.Scheme}://{Request.Host}";
        var returnUrl = $"{baseUrl}/payment/success";

        var command = new PurchaseCreditsCommand(
            request.CreditPackageId, request.Provider,
            request.PayerPhone, baseUrl, returnUrl);

        return Ok(await _mediator.Send(command, ct));
    }

    [HttpPost("callback")]
    [AllowAnonymous]
    public async Task<IActionResult> PaymentCallback([FromBody] PaymentCallbackDto callback, CancellationToken ct)
    {
        var transactionId = Guid.Parse(callback.TransactionId);
        var result = await _mediator.Send(
            new ProcessPaymentCallbackCommand(transactionId, callback.Provider, callback.Data), ct);
        return result ? Ok() : BadRequest();
    }

    /// <summary>
    /// Dedicated Swish callback endpoint — matches actual Swish callback JSON format.
    /// Swish posts: { id, payeePaymentReference (our transactionId), status, amount, ... }
    /// </summary>
    [HttpPost("swish/callback")]
    [AllowAnonymous]
    public async Task<IActionResult> SwishCallback([FromBody] JsonElement body, CancellationToken ct)
    {
        try
        {
            if (!body.TryGetProperty("payeePaymentReference", out var refProp))
                return BadRequest("Missing payeePaymentReference");

            var refStr = refProp.GetString();
            if (!Guid.TryParse(refStr, out var transactionId))
                return BadRequest("Invalid payeePaymentReference");

            var callbackData = body.GetRawText();
            var result = await _mediator.Send(
                new ProcessPaymentCallbackCommand(transactionId, "swish", callbackData), ct);

            return result ? Ok() : BadRequest("Payment validation failed");
        }
        catch (Exception ex)
        {
            return BadRequest(ex.Message);
        }
    }

    /// <summary>
    /// Frontend polls this endpoint to check Swish payment status.
    /// Calls the Swish MSS status API and processes payment if PAID.
    /// </summary>
    [HttpGet("swish/status/{instructionId}")]
    public async Task<IActionResult> SwishStatus(string instructionId, CancellationToken ct)
    {
        try
        {
            var swishService = _paymentFactory.GetService(Minion.Domain.Enums.PaymentProvider.Swish);
            var statusResult = await swishService.CheckStatusAsync(instructionId, ct);

            // If payment is completed, trigger credit processing
            if (statusResult.Status == Minion.Domain.Enums.PaymentStatus.Completed)
            {
                // Find transaction by ExternalPaymentId and process if still pending
                var tx = await _mediator.Send(new GetTransactionByExternalIdQuery(instructionId), ct);
                if (tx != null && tx.Status == "Pending")
                {
                    // Build synthetic Swish callback payload and process
                    var fakeCallback = System.Text.Json.JsonSerializer.Serialize(new
                    {
                        id = instructionId,
                        payeePaymentReference = tx.TransactionId.ToString(),
                        status = "PAID"
                    });
                    await _mediator.Send(
                        new ProcessPaymentCallbackCommand(tx.TransactionId, "swish", fakeCallback), ct);
                }
            }

            return Ok(new
            {
                instructionId,
                status = statusResult.Status.ToString(),
                errorMessage = statusResult.ErrorMessage
            });
        }
        catch (Exception ex)
        {
            return Ok(new { instructionId, status = "Error", errorMessage = ex.Message });
        }
    }

    [HttpGet("providers")]
    [AllowAnonymous]
    public IActionResult GetProviders()
    {
        return Ok(new[]
        {
            new { id = "swish", name = "Swish", icon = "swish", description = "Betala med Swish" },
            new { id = "paypal", name = "PayPal", icon = "paypal", description = "Pay with PayPal" },
            new { id = "klarna", name = "Klarna", icon = "klarna", description = "Betala med Klarna" }
        });
    }
}

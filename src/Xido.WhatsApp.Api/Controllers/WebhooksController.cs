using Microsoft.AspNetCore.Mvc;
using Xido.WhatsApp.Api.Data;

namespace Xido.WhatsApp.Api.Controllers;

/// <summary>
/// Receives inbound webhooks from WhatsApp providers.
/// Each provider has its own endpoint — configure the webhook URL in the provider dashboard.
///
/// AiSensy:  POST /api/webhooks/aisensy
/// WATI:     POST /api/webhooks/wati
/// Twilio:   POST /api/webhooks/twilio
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class WebhooksController(
    AppDbContext db,
    ILogger<WebhooksController> logger) : ControllerBase
{
    /// <summary>AiSensy inbound webhook</summary>
    [HttpPost("aisensy")]
    public async Task<IActionResult> AiSensy([FromBody] object payload, CancellationToken ct)
    {
        logger.LogInformation("[Webhook/AiSensy] Received: {Payload}", payload);
        // TODO: parse AiSensy payload and store/forward as needed
        return Ok();
    }

    /// <summary>WATI inbound webhook</summary>
    [HttpPost("wati")]
    public async Task<IActionResult> Wati([FromBody] object payload, CancellationToken ct)
    {
        logger.LogInformation("[Webhook/Wati] Received: {Payload}", payload);
        // TODO: parse WATI payload and store/forward as needed
        return Ok();
    }

    /// <summary>Twilio inbound webhook (form-encoded)</summary>
    [HttpPost("twilio")]
    [Consumes("application/x-www-form-urlencoded")]
    public IActionResult Twilio([FromForm] IFormCollection form)
    {
        var from = form["From"].ToString();
        var body = form["Body"].ToString();
        logger.LogInformation("[Webhook/Twilio] From: {From} | Body: {Body}", from, body);
        // TODO: parse Twilio form payload and store/forward as needed
        return Ok();
    }
}

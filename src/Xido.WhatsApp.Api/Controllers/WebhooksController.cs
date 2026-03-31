using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Xido.WhatsApp.Api.Data;
using Xido.WhatsApp.Api.Models;

namespace Xido.WhatsApp.Api.Controllers;

/// <summary>
/// Receives inbound webhooks from WhatsApp providers.
/// Configure these URLs in the provider dashboard:
///   AiSensy → POST /api/webhooks/aisensy
///   WATI    → POST /api/webhooks/wati
///   Twilio  → POST /api/webhooks/twilio
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class WebhooksController(
    AppDbContext db,
    ILogger<WebhooksController> logger) : ControllerBase
{
    // ── AiSensy ──────────────────────────────────────────────────────────────

    [HttpPost("aisensy")]
    public async Task<IActionResult> AiSensy([FromBody] JsonElement payload, CancellationToken ct)
    {
        var raw  = payload.GetRawText();
        var from = payload.TryGetProperty("from", out var f) ? f.GetString() ?? "" : "";
        var body = payload.TryGetProperty("message", out var m) ? m.GetString() ?? "" : "";
        var name = payload.TryGetProperty("senderName", out var s) ? s.GetString() : null;

        logger.LogInformation("[Webhook/AiSensy] From: {From} | Body: {Body}", from, body);

        await SaveInbound(from, name, body, null, null, "AiSensy", raw, ct);
        return Ok();
    }

    // ── WATI ─────────────────────────────────────────────────────────────────

    [HttpPost("wati")]
    public async Task<IActionResult> Wati([FromBody] JsonElement payload, CancellationToken ct)
    {
        var raw  = payload.GetRawText();
        var from = payload.TryGetProperty("waId", out var w) ? w.GetString() ?? "" : "";
        var name = payload.TryGetProperty("senderName", out var s) ? s.GetString() : null;

        string body = "";
        if (payload.TryGetProperty("text", out var text) &&
            text.TryGetProperty("body", out var b))
            body = b.GetString() ?? "";

        // WATI image/document
        string? mediaUrl  = null;
        string? mediaType = null;
        if (payload.TryGetProperty("type", out var type))
        {
            var msgType = type.GetString();
            if (msgType == "image" &&
                payload.TryGetProperty("image", out var img) &&
                img.TryGetProperty("link", out var link))
            {
                mediaUrl  = link.GetString();
                mediaType = "image";
            }
        }

        logger.LogInformation("[Webhook/Wati] From: {From} | Body: {Body} | Media: {Media}", from, body, mediaUrl);

        await SaveInbound(from, name, body, mediaUrl, mediaType, "Wati", raw, ct);
        return Ok();
    }

    // ── Twilio ────────────────────────────────────────────────────────────────

    [HttpPost("twilio")]
    [Consumes("application/x-www-form-urlencoded")]
    public async Task<IActionResult> Twilio([FromForm] IFormCollection form, CancellationToken ct)
    {
        var from      = form["From"].ToString().Replace("whatsapp:", "");
        var body      = form["Body"].ToString();
        var numMedia  = int.TryParse(form["NumMedia"], out var n) ? n : 0;
        var mediaUrl  = numMedia > 0 ? form["MediaUrl0"].ToString() : null;
        var mediaType = numMedia > 0 ? form["MediaContentType0"].ToString() : null;

        var raw = string.Join("&", form.Keys.Select(k => $"{k}={form[k]}"));

        logger.LogInformation("[Webhook/Twilio] From: {From} | Body: {Body} | Media: {NumMedia}", from, body, numMedia);

        await SaveInbound(from, null, body, mediaUrl, mediaType, "Twilio", raw, ct);

        // Twilio expects TwiML response (empty is fine for WhatsApp)
        return Content("<Response/>", "text/xml");
    }

    // ── Inbound messages list ─────────────────────────────────────────────────

    /// <summary>List received inbound messages (newest first)</summary>
    [HttpGet("inbound")]
    [ProducesResponseType(typeof(List<InboundMessageDto>), 200)]
    public async Task<IActionResult> ListInbound(
        [FromQuery] int    page     = 1,
        [FromQuery] int    pageSize = 50,
        [FromQuery] string? phone   = null,
        CancellationToken ct = default)
    {
        pageSize = Math.Clamp(pageSize, 1, 200);
        page     = Math.Max(1, page);

        var query = db.InboundMessages.AsQueryable();
        if (!string.IsNullOrWhiteSpace(phone))
            query = query.Where(x => x.FromPhone.Contains(phone));

        var items = await query
            .OrderByDescending(x => x.ReceivedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(x => new InboundMessageDto
            {
                Id         = x.Id,
                FromPhone  = x.FromPhone,
                SenderName = x.SenderName,
                Body       = x.Body,
                MediaUrl   = x.MediaUrl,
                MediaType  = x.MediaType,
                Provider   = x.Provider,
                ReceivedAt = x.ReceivedAt,
            })
            .ToListAsync(ct);

        return Ok(items);
    }

    // ── Private helper ────────────────────────────────────────────────────────

    private async Task SaveInbound(
        string from, string? name, string body,
        string? mediaUrl, string? mediaType,
        string provider, string raw, CancellationToken ct)
    {
        var msg = new InboundMessage
        {
            FromPhone  = from.Length > 30 ? from[..30] : from,
            SenderName = name,
            Body       = body.Length > 4096 ? body[..4096] : body,
            MediaUrl   = mediaUrl,
            MediaType  = mediaType,
            Provider   = provider,
            RawPayload = raw.Length > 8192 ? raw[..8192] : raw,
        };
        db.InboundMessages.Add(msg);
        await db.SaveChangesAsync(ct);
    }
}

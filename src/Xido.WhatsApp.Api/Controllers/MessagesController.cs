using System.Globalization;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Xido.WhatsApp.Api.Data;
using Xido.WhatsApp.Api.Helpers;
using Xido.WhatsApp.Api.Models;
using Xido.WhatsApp.Api.Services;

namespace Xido.WhatsApp.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MessagesController(
    WhatsAppRouter router,
    AppDbContext   db,
    ILogger<MessagesController> logger) : ControllerBase
{
    /// <summary>Send a WhatsApp message (simple or delegation request). MediaUrl triggers MMS (Twilio only).</summary>
    [HttpPost("send")]
    [ProducesResponseType(typeof(SendMessageResponse), 200)]
    [ProducesResponseType(400)]
    public async Task<IActionResult> Send([FromBody] SendMessageRequest req, CancellationToken ct)
    {
        var phone = PhoneNormalizer.Normalize(req.ToPhone);
        if (phone is null)
            return BadRequest(new { error = $"Invalid phone number: {req.ToPhone}" });

        string body;
        if (req.MessageType.Equals("delegation", StringComparison.OrdinalIgnoreCase))
        {
            if (req.GrantorName is null || req.OrgName is null ||
                req.OperationNames is null || req.ValidFrom is null || req.ValidTo is null)
                return BadRequest(new { error = "Delegation type requires: grantorName, orgName, operationNames, validFrom, validTo" });

            body = BuildDelegationText(
                req.RecipientName ?? phone,
                req.GrantorName, req.OrgName, req.OperationNames,
                req.ValidFrom.Value, req.ValidTo.Value, req.Notes);
        }
        else
        {
            if (string.IsNullOrWhiteSpace(req.Message))
                return BadRequest(new { error = "Simple type requires message field" });
            body = req.Message;
        }

        var provider = router.GetProvider();

        var log = new MessageLog
        {
            RecipientPhone = phone,
            RecipientName  = req.RecipientName,
            Body           = body.Length > 4096 ? body[..4096] : body,
            MediaUrl       = req.MediaUrl,
            Provider       = provider.ProviderName,
            Status         = "queued",
        };
        db.MessageLogs.Add(log);
        await db.SaveChangesAsync(ct);

        var (status, externalId, error) = await router.SendAsync(phone, req.RecipientName, body, req.MediaUrl, ct);

        log.Status       = status;
        log.ExternalId   = externalId;
        log.ErrorMessage = error;
        log.UpdatedAt    = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);

        return Ok(new SendMessageResponse
        {
            MessageId    = log.Id,
            Status       = log.Status,
            Provider     = log.Provider,
            HasMedia     = req.MediaUrl != null,
            ExternalId   = log.ExternalId,
            ErrorMessage = log.ErrorMessage,
        });
    }

    /// <summary>Get a single sent message by ID</summary>
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(MessageLogDto), 200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> GetById(Guid id, CancellationToken ct)
    {
        var x = await db.MessageLogs.FindAsync([id], ct);
        if (x is null) return NotFound();

        return Ok(new MessageLogDto
        {
            Id             = x.Id,
            RecipientPhone = x.RecipientPhone,
            RecipientName  = x.RecipientName,
            Body           = x.Body,
            MediaUrl       = x.MediaUrl,
            Provider       = x.Provider,
            Status         = x.Status,
            ExternalId     = x.ExternalId,
            ErrorMessage   = x.ErrorMessage,
            CreatedAt      = x.CreatedAt,
            UpdatedAt      = x.UpdatedAt,
        });
    }

    /// <summary>List sent messages (newest first)</summary>
    [HttpGet]
    [ProducesResponseType(typeof(List<MessageLogDto>), 200)]
    public async Task<IActionResult> List(
        [FromQuery] int     page     = 1,
        [FromQuery] int     pageSize = 50,
        [FromQuery] string? phone    = null,
        [FromQuery] string? status   = null,
        CancellationToken ct = default)
    {
        pageSize = Math.Clamp(pageSize, 1, 200);
        page     = Math.Max(1, page);

        var query = db.MessageLogs.AsQueryable();
        if (!string.IsNullOrWhiteSpace(phone))
            query = query.Where(x => x.RecipientPhone.Contains(phone));
        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(x => x.Status == status);

        var items = await query
            .OrderByDescending(x => x.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(x => new MessageLogDto
            {
                Id             = x.Id,
                RecipientPhone = x.RecipientPhone,
                RecipientName  = x.RecipientName,
                Body           = x.Body,
                MediaUrl       = x.MediaUrl,
                Provider       = x.Provider,
                Status         = x.Status,
                ExternalId     = x.ExternalId,
                ErrorMessage   = x.ErrorMessage,
                CreatedAt      = x.CreatedAt,
                UpdatedAt      = x.UpdatedAt,
            })
            .ToListAsync(ct);

        return Ok(items);
    }

    private static string BuildDelegationText(
        string toName, string grantorName, string orgName,
        string operationNames, DateTime validFrom, DateTime validTo, string? notes)
    {
        var sb = new StringBuilder();
        sb.AppendLine("⚡ *Minion – Yeni Yetki Talebi*");
        sb.AppendLine();
        sb.AppendLine($"Merhaba *{toName}*,");
        sb.AppendLine();
        sb.AppendLine($"*{grantorName}* sizi *{orgName}* kurumunda yetkilendirmek istiyor.");
        sb.AppendLine();
        sb.AppendLine($"📋 *İşlemler:* {operationNames}");
        sb.AppendLine($"📅 *Geçerlilik:* {validFrom.ToString("dd.MM.yyyy HH:mm", CultureInfo.InvariantCulture)} – {validTo.ToString("dd.MM.yyyy HH:mm", CultureInfo.InvariantCulture)}");
        if (!string.IsNullOrWhiteSpace(notes))
            sb.AppendLine($"📝 *Not:* {notes}");
        sb.AppendLine();
        sb.AppendLine("👉 Kabul veya reddetmek için Minion uygulamasını açın.");
        return sb.ToString().TrimEnd();
    }
}

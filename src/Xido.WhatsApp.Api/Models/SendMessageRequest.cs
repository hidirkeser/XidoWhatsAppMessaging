using System.ComponentModel.DataAnnotations;

namespace Xido.WhatsApp.Api.Models;

public class SendMessageRequest
{
    [Required]
    public string ToPhone { get; set; } = string.Empty;

    public string? RecipientName { get; set; }

    /// <summary>simple | delegation</summary>
    [Required]
    public string MessageType { get; set; } = "simple";

    // ── Simple message ────────────────────────────────────────────────
    public string? Message { get; set; }

    /// <summary>
    /// Optional public URL of an image or video to attach (MMS).
    /// Only supported by Twilio. AiSensy and WATI will send text only.
    /// </summary>
    public string? MediaUrl { get; set; }

    // ── Delegation fields ─────────────────────────────────────────────
    public string?   GrantorName     { get; set; }
    public string?   OrgName         { get; set; }
    public string?   OperationNames  { get; set; }
    public DateTime? ValidFrom       { get; set; }
    public DateTime? ValidTo         { get; set; }
    public string?   Notes           { get; set; }
    public string?   AcceptUrl       { get; set; }
    public string?   RejectUrl       { get; set; }
}

public class SendMessageResponse
{
    public Guid    MessageId    { get; set; }
    public string  Status       { get; set; } = string.Empty;
    public string  Provider     { get; set; } = string.Empty;
    public bool    HasMedia     { get; set; }
    public string? ExternalId   { get; set; }
    public string? ErrorMessage { get; set; }
}

public class MessageLogDto
{
    public Guid     Id             { get; set; }
    public string   RecipientPhone { get; set; } = string.Empty;
    public string?  RecipientName  { get; set; }
    public string   Body           { get; set; } = string.Empty;
    public string?  MediaUrl       { get; set; }
    public string   Provider       { get; set; } = string.Empty;
    public string   Status         { get; set; } = string.Empty;
    public string?  ExternalId     { get; set; }
    public string?  ErrorMessage   { get; set; }
    public DateTime CreatedAt      { get; set; }
    public DateTime UpdatedAt      { get; set; }
}

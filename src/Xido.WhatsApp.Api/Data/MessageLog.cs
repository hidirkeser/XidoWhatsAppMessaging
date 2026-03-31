namespace Xido.WhatsApp.Api.Data;

public class MessageLog
{
    public Guid     Id             { get; set; } = Guid.NewGuid();
    public string   RecipientPhone { get; set; } = string.Empty;
    public string?  RecipientName  { get; set; }
    public string   Body           { get; set; } = string.Empty;
    public string   Provider       { get; set; } = string.Empty;
    public string   Status         { get; set; } = "queued";
    public string?  ExternalId     { get; set; }
    public string?  ErrorMessage   { get; set; }
    public DateTime CreatedAt      { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt      { get; set; } = DateTime.UtcNow;
}

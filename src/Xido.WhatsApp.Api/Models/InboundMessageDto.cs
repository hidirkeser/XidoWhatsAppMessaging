namespace Xido.WhatsApp.Api.Models;

public class InboundMessageDto
{
    public Guid     Id         { get; set; }
    public string   FromPhone  { get; set; } = string.Empty;
    public string?  SenderName { get; set; }
    public string   Body       { get; set; } = string.Empty;
    public string?  MediaUrl   { get; set; }
    public string?  MediaType  { get; set; }
    public string   Provider   { get; set; } = string.Empty;
    public DateTime ReceivedAt { get; set; }
}

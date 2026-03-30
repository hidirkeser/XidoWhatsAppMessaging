namespace Minion.Domain.Entities;

public class UserNotificationPreference
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }

    public bool InAppEnabled  { get; set; } = true;
    public bool PushEnabled   { get; set; } = true;
    public bool EmailEnabled  { get; set; } = true;
    public bool WhatsAppEnabled { get; set; } = false;
    public bool SmsEnabled    { get; set; } = false;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    public User User { get; set; } = null!;
}

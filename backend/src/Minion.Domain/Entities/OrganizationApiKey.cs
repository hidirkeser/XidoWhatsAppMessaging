using Minion.Domain.Common;

namespace Minion.Domain.Entities;

public class OrganizationApiKey : BaseEntity
{
    public Guid   OrganizationId  { get; set; }
    public string Name            { get; set; } = string.Empty;
    public string KeyId           { get; set; } = string.Empty;  // public identifier
    public string SecretHash      { get; set; } = string.Empty;  // BCrypt hash, never exposed
    public bool   IsActive        { get; set; } = true;
    public DateTime? LastUsedAt   { get; set; }
    public int    RequestCount    { get; set; } = 0;
    public Guid   CreatedByUserId { get; set; }

    public Organization Organization { get; set; } = null!;
}

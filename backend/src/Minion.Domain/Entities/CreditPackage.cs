using Minion.Domain.Common;

namespace Minion.Domain.Entities;

public class CreditPackage : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? NameSv { get; set; }
    public int CreditAmount { get; set; }
    public decimal PriceSEK { get; set; }
    public string? Description { get; set; }
    public string? DescriptionSv { get; set; }
    public string? Badge { get; set; }
    public string? BadgeSv { get; set; }
    public bool IsActive { get; set; } = true;
    public int SortOrder { get; set; }
}

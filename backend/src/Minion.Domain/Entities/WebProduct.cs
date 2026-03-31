using Minion.Domain.Common;

namespace Minion.Domain.Entities;

public class WebProduct : BaseEntity
{
    public string Slug { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;

    // English
    public string NameEn { get; set; } = string.Empty;
    public string DescriptionEn { get; set; } = string.Empty;
    public string FeaturesEn { get; set; } = "[]";

    // Swedish
    public string NameSv { get; set; } = string.Empty;
    public string DescriptionSv { get; set; } = string.Empty;
    public string FeaturesSv { get; set; } = "[]";

    public bool IsActive { get; set; } = true;
    public int SortOrder { get; set; }
}

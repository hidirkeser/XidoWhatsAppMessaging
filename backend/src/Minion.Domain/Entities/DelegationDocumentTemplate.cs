using Minion.Domain.Common;

namespace Minion.Domain.Entities;

public class DelegationDocumentTemplate : BaseEntity
{
    public string Language { get; set; } = string.Empty;        // "tr", "en", "sv", "de", "es", "fr"
    public string LanguageName { get; set; } = string.Empty;    // "Turkce", "English", "Svenska"...
    public string TemplateContent { get; set; } = string.Empty; // HTML with {{placeholders}}
    public string Version { get; set; } = "1.0";
    public bool IsActive { get; set; } = true;
}

using Minion.Domain.Common;
using Minion.Domain.Enums;

namespace Minion.Domain.Entities;

public class DelegationDocument : BaseEntity
{
    public Guid DelegationId { get; set; }
    public string Language { get; set; } = "tr";
    public string RenderedContent { get; set; } = string.Empty;
    public string DocumentVersion { get; set; } = "1.0";
    public DocumentStatus Status { get; set; } = DocumentStatus.Draft;

    public DateTime? GrantorApprovedAt { get; set; }
    public string? GrantorSignature { get; set; }
    public DateTime? DelegateApprovedAt { get; set; }
    public string? DelegateSignature { get; set; }
    public string? QrCodeData { get; set; }

    // Navigation
    public Delegation Delegation { get; set; } = null!;
    public ICollection<DelegationDocumentLog> Logs { get; set; } = new List<DelegationDocumentLog>();
}

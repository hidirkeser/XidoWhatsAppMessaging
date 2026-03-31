namespace Minion.Domain.Interfaces;

public interface IDocumentPdfService
{
    Task<byte[]> GeneratePdfAsync(Guid documentId, CancellationToken ct = default);
    Task<byte[]> GeneratePdfFromHtmlAsync(string htmlContent, string verificationCode, CancellationToken ct = default);
}

using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace Minion.Infrastructure.Services;

public class DocumentPdfService : IDocumentPdfService
{
    private readonly IApplicationDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly ILogger<DocumentPdfService> _logger;

    static DocumentPdfService()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    public DocumentPdfService(
        IApplicationDbContext context,
        IConfiguration configuration,
        ILogger<DocumentPdfService> logger)
    {
        _context = context;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<byte[]> GeneratePdfAsync(Guid documentId, CancellationToken ct = default)
    {
        var doc = await _context.DelegationDocuments
            .Include(d => d.Delegation).ThenInclude(del => del.GrantorUser)
            .Include(d => d.Delegation).ThenInclude(del => del.DelegateUser)
            .Include(d => d.Delegation).ThenInclude(del => del.Organization)
            .Include(d => d.Delegation).ThenInclude(del => del.DelegationOperations)
                .ThenInclude(op => op.OperationType)
            .FirstOrDefaultAsync(d => d.Id == documentId, ct)
            ?? throw new NotFoundException("DelegationDocument", documentId);

        var delegation = doc.Delegation;
        var operations = string.Join(", ",
            delegation.DelegationOperations.Select(op => op.OperationType.Name));

        var isSwedish = doc.Language == "sv";
        var qrUrl = $"{_configuration["AppBaseUrl"]?.TrimEnd('/')}/verify/{delegation.VerificationCode}/document";

        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.MarginTop(40);
                page.MarginBottom(30);
                page.MarginHorizontal(50);
                page.DefaultTextStyle(x => x.FontSize(10).FontColor(Colors.Black));

                page.Header().Column(col =>
                {
                    col.Item().AlignCenter().Text(isSwedish ? "FULLMAKT" : "POWER OF ATTORNEY")
                        .FontSize(22).Bold().LetterSpacing(2);
                    col.Item().AlignCenter().Text(isSwedish ? "Power of Attorney" : "Fullmakt")
                        .FontSize(11).FontColor(Colors.Grey.Medium);
                    col.Item().PaddingTop(6).AlignCenter()
                        .Text(isSwedish
                            ? "Upprattad inom ramen for svensk ratt, sarskilt avtalslagen (1915:218)"
                            : "Drawn up within the framework of Swedish law, in particular the Contracts Act (1915:218)")
                        .FontSize(8).FontColor(Colors.Grey.Medium);
                    col.Item().PaddingVertical(10).LineHorizontal(2).LineColor(Colors.Amber.Medium);
                });

                page.Content().Column(col =>
                {
                    // Parties
                    col.Item().PaddingBottom(10).Column(inner =>
                    {
                        inner.Item().Text(isSwedish ? "PARTER" : "PARTIES")
                            .FontSize(11).Bold().FontColor(Colors.Amber.Darken2);
                        inner.Item().PaddingTop(6).Row(row =>
                        {
                            row.RelativeItem().Column(c =>
                            {
                                c.Item().Text(isSwedish ? "Fullmaktsgivare" : "Principal (Grantor)")
                                    .FontSize(8).FontColor(Colors.Grey.Medium);
                                c.Item().Text(delegation.GrantorUser.FullName).Bold();
                                c.Item().Text($"ID: {MaskPersonalNumber(delegation.GrantorUser.PersonalNumber)}")
                                    .FontSize(9).FontColor(Colors.Grey.Darken1);
                                c.Item().Text($"Org: {delegation.Organization.Name}")
                                    .FontSize(9).FontColor(Colors.Grey.Darken1);
                                c.Item().Text($"Org.nr: {delegation.Organization.OrgNumber}")
                                    .FontSize(9).FontColor(Colors.Grey.Darken1);
                            });
                            row.RelativeItem().Column(c =>
                            {
                                c.Item().Text(isSwedish ? "Fullmaktshavare" : "Agent (Representative)")
                                    .FontSize(8).FontColor(Colors.Grey.Medium);
                                c.Item().Text(delegation.DelegateUser.FullName).Bold();
                                c.Item().Text($"ID: {MaskPersonalNumber(delegation.DelegateUser.PersonalNumber)}")
                                    .FontSize(9).FontColor(Colors.Grey.Darken1);
                            });
                        });
                    });

                    // Section 1: Purpose
                    col.Item().PaddingBottom(10).Column(inner =>
                    {
                        inner.Item().Text(isSwedish
                                ? "\u00a7 1 \u2013 Syfte och omfattning"
                                : "\u00a7 1 \u2013 Purpose and Scope")
                            .FontSize(12).Bold();
                        inner.Item().PaddingTop(4).Text(isSwedish
                                ? "Fullmaktsgivaren bemyndigar harmed fullmaktshavaren att sjalvstandigt agera pa fullmaktsgivarens vagnar inom foljande omraden:"
                                : "The Principal hereby authorises the Agent to act independently on behalf of the Principal in the following areas:")
                            .FontSize(10).LineHeight(1.4f);
                        inner.Item().PaddingTop(6).Border(1).BorderColor(Colors.Grey.Lighten2)
                            .Padding(8).Text(operations).Bold();
                    });

                    // Section 2: Validity
                    col.Item().PaddingBottom(10).Column(inner =>
                    {
                        inner.Item().Text(isSwedish
                                ? "\u00a7 2 \u2013 Giltighetstid"
                                : "\u00a7 2 \u2013 Validity Period")
                            .FontSize(12).Bold();
                        inner.Item().PaddingTop(6).Row(row =>
                        {
                            row.RelativeItem().Column(c =>
                            {
                                c.Item().Text(isSwedish ? "Giltig fran" : "Valid From")
                                    .FontSize(8).FontColor(Colors.Grey.Medium);
                                c.Item().Text(delegation.ValidFrom.ToString("dd.MM.yyyy HH:mm"))
                                    .Bold().FontColor(Colors.Green.Darken2);
                            });
                            row.RelativeItem().Column(c =>
                            {
                                c.Item().Text(isSwedish ? "Giltig till" : "Valid Until")
                                    .FontSize(8).FontColor(Colors.Grey.Medium);
                                c.Item().Text(delegation.ValidTo.ToString("dd.MM.yyyy HH:mm"))
                                    .Bold().FontColor(Colors.Red.Darken2);
                            });
                        });
                    });

                    // Section 3: Obligations
                    col.Item().PaddingBottom(10).Column(inner =>
                    {
                        inner.Item().Text(isSwedish
                                ? "\u00a7 3 \u2013 Fullmaktshavarens skyldigheter"
                                : "\u00a7 3 \u2013 Agent\u2019s Obligations")
                            .FontSize(12).Bold();
                        inner.Item().PaddingTop(4).Text(isSwedish
                                ? "\u2022 Agera i enlighet med fullmaktsgivarens intressen\n\u2022 Informera fullmaktsgivaren om genomforda transaktioner\n\u2022 Inte overfora denna fullmakt utan skriftligt medgivande"
                                : "\u2022 Act in accordance with the interests of the Principal\n\u2022 Inform the Principal of transactions carried out\n\u2022 Not transfer this power of attorney without written consent")
                            .FontSize(10).LineHeight(1.6f);
                    });

                    // Section 4: Revocation
                    col.Item().PaddingBottom(10).Column(inner =>
                    {
                        inner.Item().Text(isSwedish
                                ? "\u00a7 4 \u2013 Aterkallelse"
                                : "\u00a7 4 \u2013 Revocation")
                            .FontSize(12).Bold();
                        inner.Item().PaddingTop(4).Text(isSwedish
                                ? "Fullmaktsgivaren forbehaller sig ratten att nar som helst aterkalla denna fullmakt."
                                : "The Principal reserves the right to revoke this power of attorney at any time by written notice.")
                            .FontSize(10).LineHeight(1.4f);
                    });

                    // Section 5: Applicable Law
                    col.Item().PaddingBottom(10).Column(inner =>
                    {
                        inner.Item().Text(isSwedish
                                ? "\u00a7 5 \u2013 Tillamlig lag"
                                : "\u00a7 5 \u2013 Applicable Law")
                            .FontSize(12).Bold();
                        inner.Item().PaddingTop(4).Text(isSwedish
                                ? "Denna fullmakt lyder under svensk ratt."
                                : "This power of attorney is governed by Swedish law.")
                            .FontSize(10).LineHeight(1.4f);
                    });

                    // Notes
                    if (!string.IsNullOrWhiteSpace(delegation.Notes) && delegation.Notes != "-")
                    {
                        col.Item().PaddingBottom(10).Column(inner =>
                        {
                            inner.Item().Text(isSwedish ? "Anteckningar" : "Notes")
                                .FontSize(12).Bold();
                            inner.Item().PaddingTop(4).Text(delegation.Notes)
                                .FontSize(10).Italic().FontColor(Colors.Grey.Darken1);
                        });
                    }

                    // Signatures
                    col.Item().PaddingBottom(10).Background(Colors.Grey.Lighten4).Padding(12).Column(inner =>
                    {
                        inner.Item().Text(isSwedish ? "UNDERSKRIFTER" : "SIGNATURES")
                            .FontSize(11).Bold().FontColor(Colors.Amber.Darken2);
                        inner.Item().PaddingTop(8).Row(row =>
                        {
                            row.RelativeItem().Border(1).BorderColor(Colors.Grey.Lighten2)
                                .Background(Colors.White).Padding(10).Column(c =>
                            {
                                c.Item().Text(isSwedish ? "Fullmaktsgivare" : "Principal")
                                    .FontSize(8).FontColor(Colors.Grey.Medium);
                                c.Item().Text(delegation.GrantorUser.FullName).Bold();
                                c.Item().PaddingTop(4).Text(isSwedish ? "BankID underskrift:" : "BankID Signature:")
                                    .FontSize(8).FontColor(Colors.Grey.Medium);
                                c.Item().Text(doc.GrantorApprovedAt.HasValue
                                        ? $"Signed: {doc.GrantorApprovedAt.Value:yyyy-MM-dd HH:mm:ss} UTC"
                                        : "[Pending]")
                                    .FontSize(9).FontColor(doc.GrantorApprovedAt.HasValue
                                        ? Colors.Green.Darken2 : Colors.Orange.Darken2);
                            });
                            row.ConstantItem(10);
                            row.RelativeItem().Border(1).BorderColor(Colors.Grey.Lighten2)
                                .Background(Colors.White).Padding(10).Column(c =>
                            {
                                c.Item().Text(isSwedish ? "Fullmaktshavare" : "Agent")
                                    .FontSize(8).FontColor(Colors.Grey.Medium);
                                c.Item().Text(delegation.DelegateUser.FullName).Bold();
                                c.Item().PaddingTop(4).Text(isSwedish ? "BankID underskrift:" : "BankID Signature:")
                                    .FontSize(8).FontColor(Colors.Grey.Medium);
                                c.Item().Text(doc.DelegateApprovedAt.HasValue
                                        ? $"Signed: {doc.DelegateApprovedAt.Value:yyyy-MM-dd HH:mm:ss} UTC"
                                        : "[Pending]")
                                    .FontSize(9).FontColor(doc.DelegateApprovedAt.HasValue
                                        ? Colors.Green.Darken2 : Colors.Orange.Darken2);
                            });
                        });
                    });

                    // Verification
                    col.Item().PaddingBottom(10).AlignCenter().Column(inner =>
                    {
                        inner.Item().AlignCenter().Text(isSwedish ? "VERIFIERING" : "VERIFICATION")
                            .FontSize(9).FontColor(Colors.Grey.Medium).LetterSpacing(1);
                        inner.Item().PaddingTop(4).AlignCenter()
                            .Text($"Code: {delegation.VerificationCode}").Bold();
                        inner.Item().AlignCenter().Text(qrUrl)
                            .FontSize(9).FontColor(Colors.Amber.Darken2);
                    });
                });

                page.Footer().AlignCenter().Text(text =>
                {
                    text.Span($"v{doc.DocumentVersion} \u2022 {doc.CreatedAt:dd.MM.yyyy HH:mm} \u2022 Powered by Minion")
                        .FontSize(8).FontColor(Colors.Grey.Medium);
                });
            });
        }).GeneratePdf();
    }

    public Task<byte[]> GeneratePdfFromHtmlAsync(string htmlContent, string verificationCode, CancellationToken ct = default)
    {
        // For public preview purposes — simplified PDF from plain text extraction
        var pdf = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(50);
                page.Content().Text(htmlContent).FontSize(10);
                page.Footer().AlignCenter().Text($"Verification: {verificationCode}")
                    .FontSize(8).FontColor(Colors.Grey.Medium);
            });
        }).GeneratePdf();

        return Task.FromResult(pdf);
    }

    private static string MaskPersonalNumber(string personalNumber)
    {
        if (personalNumber.Length >= 10)
            return personalNumber[..8] + "-****";
        return personalNumber;
    }
}

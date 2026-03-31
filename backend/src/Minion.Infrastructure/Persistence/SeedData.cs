using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Minion.Domain.Entities;
using Minion.Domain.Enums;

namespace Minion.Infrastructure.Persistence;

public static class SeedData
{
    public static async Task InitializeAsync(IServiceProvider serviceProvider)
    {
        using var scope = serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<ApplicationDbContext>>();

        try
        {
            await context.Database.MigrateAsync();
            logger.LogInformation("Database migrated successfully");

            if (!await context.Users.AnyAsync())
            {
                await SeedUsersAsync(context);
                await SeedOrganizationsAsync(context);
                await SeedCreditPackagesAsync(context);
                logger.LogInformation("Seed data created successfully");
            }

            if (!await context.Products.AnyAsync())
            {
                await SeedProductsAsync(context);
                logger.LogInformation("Product seed data created successfully");
            }

            if (!await context.DelegationDocumentTemplates.AnyAsync())
            {
                await SeedDocumentTemplatesAsync(context);
                logger.LogInformation("Document template seed data created successfully");
            }
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error seeding database");
        }
    }

    private static async Task SeedUsersAsync(ApplicationDbContext context)
    {
        var adminUser = new User
        {
            Id = Guid.Parse("00000000-0000-0000-0000-000000000001"),
            PersonalNumber = "199001011234",
            FirstName = "Admin",
            LastName = "Användare",
            Email = "admin@minion.se",
            IsAdmin = true,
            IsActive = true
        };

        var testUser = new User
        {
            Id = Guid.Parse("00000000-0000-0000-0000-000000000002"),
            PersonalNumber = "199505051234",
            FirstName = "Test",
            LastName = "Användare",
            Email = "test@minion.se",
            IsActive = true
        };

        context.Users.AddRange(adminUser, testUser);

        context.UserCredits.AddRange(
            new UserCredit { Id = Guid.NewGuid(), UserId = adminUser.Id, Balance = 100 },
            new UserCredit { Id = Guid.NewGuid(), UserId = testUser.Id, Balance = 10 }
        );

        await context.SaveChangesAsync();
    }

    private static async Task SeedOrganizationsAsync(ApplicationDbContext context)
    {
        var adminId = Guid.Parse("00000000-0000-0000-0000-000000000001");

        var org1 = new Organization
        {
            Id = Guid.Parse("00000000-0000-0000-0000-000000000010"),
            Name = "Minion AB",
            OrgNumber = "5566778899",
            City = "Stockholm",
            ContactEmail = "info@minion.se",
            CreatedByUserId = adminId
        };

        var org2 = new Organization
        {
            Id = Guid.Parse("00000000-0000-0000-0000-000000000020"),
            Name = "Test Foretag AB",
            OrgNumber = "1122334455",
            City = "Goteborg",
            CreatedByUserId = adminId
        };

        context.Organizations.AddRange(org1, org2);

        // Assign users to orgs
        context.UserOrganizations.AddRange(
            new UserOrganization { Id = Guid.NewGuid(), UserId = adminId, OrganizationId = org1.Id, Role = "Admin", AssignedByUserId = adminId },
            new UserOrganization { Id = Guid.NewGuid(), UserId = adminId, OrganizationId = org2.Id, Role = "Admin", AssignedByUserId = adminId },
            new UserOrganization { Id = Guid.NewGuid(), UserId = Guid.Parse("00000000-0000-0000-0000-000000000002"), OrganizationId = org1.Id, Role = "Member", AssignedByUserId = adminId }
        );

        // Operation types for org1
        context.OperationTypes.AddRange(
            new OperationType { Id = Guid.NewGuid(), OrganizationId = org1.Id, Name = "Dokumentsignering", Description = "Signera digitala dokument med BankID", Icon = "sign", CreditCost = 1, SortOrder = 1 },
            new OperationType { Id = Guid.NewGuid(), OrganizationId = org1.Id, Name = "Godkännande/Ansökan", Description = "Ge godkännande eller göra ansökningar å organisationens vägnar", Icon = "approve", CreditCost = 1, SortOrder = 2 },
            new OperationType { Id = Guid.NewGuid(), OrganizationId = org1.Id, Name = "Finansiella transaktioner", Description = "Betalning, fakturahantering, pengaöverföring", Icon = "finance", CreditCost = 2, SortOrder = 3 },
            new OperationType { Id = Guid.NewGuid(), OrganizationId = org1.Id, Name = "Avtalshantering", Description = "Skapa, redigera och avsluta avtal", Icon = "contract", CreditCost = 2, SortOrder = 4 },
            new OperationType { Id = Guid.NewGuid(), OrganizationId = org1.Id, Name = "Personalärenden", Description = "Rekrytering, ledighetsgodkännande, personaladministration", Icon = "hr", CreditCost = 1, SortOrder = 5 }
        );

        // Operation types for org2
        context.OperationTypes.AddRange(
            new OperationType { Id = Guid.NewGuid(), OrganizationId = org2.Id, Name = "Allmän representation", Description = "Utföra alla typer av ärenden för organisationen", Icon = "approve", CreditCost = 3, SortOrder = 1 },
            new OperationType { Id = Guid.NewGuid(), OrganizationId = org2.Id, Name = "Dokumentsignering", Description = "Signera digitala dokument", Icon = "sign", CreditCost = 1, SortOrder = 2 }
        );

        await context.SaveChangesAsync();
    }

    private static async Task SeedCreditPackagesAsync(ApplicationDbContext context)
    {
        context.CreditPackages.AddRange(
            new CreditPackage { Id = Guid.NewGuid(), Name = "Starter", CreditAmount = 10, PriceSEK = 49, Description = "10 kontör – perfekt för enstaka ärenden", SortOrder = 1 },
            new CreditPackage { Id = Guid.NewGuid(), Name = "Standard", CreditAmount = 50, PriceSEK = 199, Description = "50 kontör – vårt populäraste paket", SortOrder = 2 },
            new CreditPackage { Id = Guid.NewGuid(), Name = "Professional", CreditAmount = 100, PriceSEK = 349, Description = "100 kontör – för professionellt bruk", SortOrder = 3 },
            new CreditPackage { Id = Guid.NewGuid(), Name = "Enterprise", CreditAmount = 500, PriceSEK = 1499, Description = "500 kontör – för stora organisationer", SortOrder = 4 }
        );

        await context.SaveChangesAsync();
    }

    private static async Task SeedProductsAsync(ApplicationDbContext context)
    {
        var individualFeatures = new
        {
            Free = new[] { "5 delegationer/månad", "E-postsupport" },
            Basic = new[] { "50 delegationer/månad", "E-post & chatt-support", "Prioriterad hantering" },
            Premium = new[] { "Obegränsade delegationer", "Prioriterad support 24/7", "Anpassade operationstyper", "Detaljerad statistik" }
        };

        var corporateFeatures = new
        {
            Starter = new[] { "100 delegationer/månad", "API-åtkomst", "Upp till 5 användare", "E-postsupport" },
            Business = new[] { "500 delegationer/månad", "API-åtkomst", "Upp till 25 användare", "Prioriterad support", "Webhook-integration" },
            Enterprise = new[] { "Obegränsade delegationer", "API-åtkomst", "Obegränsat antal användare", "Dedikerad kundansvarig", "SLA-garanti", "Anpassad integration" }
        };

        context.Products.AddRange(
            // Individual
            new Product { Id = Guid.NewGuid(), Name = "Free", Description = "Gratis plan för privatpersoner", Type = ProductType.Individual, MonthlyQuota = 5, PriceSEK = 0, Features = JsonSerializer.Serialize(individualFeatures.Free), SortOrder = 1 },
            new Product { Id = Guid.NewGuid(), Name = "Basic", Description = "Grundläggande plan för aktiva användare", Type = ProductType.Individual, MonthlyQuota = 50, PriceSEK = 99, Features = JsonSerializer.Serialize(individualFeatures.Basic), SortOrder = 2 },
            new Product { Id = Guid.NewGuid(), Name = "Premium", Description = "Premium plan med obegränsad tillgång", Type = ProductType.Individual, MonthlyQuota = 999999, PriceSEK = 299, Features = JsonSerializer.Serialize(individualFeatures.Premium), SortOrder = 3 },

            // Corporate
            new Product { Id = Guid.NewGuid(), Name = "Starter", Description = "Startpaket för små företag", Type = ProductType.Corporate, MonthlyQuota = 100, PriceSEK = 499, Features = JsonSerializer.Serialize(corporateFeatures.Starter), SortOrder = 10 },
            new Product { Id = Guid.NewGuid(), Name = "Business", Description = "Affärsplan för medelstora företag", Type = ProductType.Corporate, MonthlyQuota = 500, PriceSEK = 1499, Features = JsonSerializer.Serialize(corporateFeatures.Business), SortOrder = 11 },
            new Product { Id = Guid.NewGuid(), Name = "Enterprise", Description = "Enterprise plan med full funktionalitet", Type = ProductType.Corporate, MonthlyQuota = 999999, PriceSEK = 4999, Features = JsonSerializer.Serialize(corporateFeatures.Enterprise), SortOrder = 12 }
        );

        await context.SaveChangesAsync();
    }

    private static async Task SeedDocumentTemplatesAsync(ApplicationDbContext context)
    {
        var templates = new List<DelegationDocumentTemplate>
        {
            // ── Turkish ──
            new()
            {
                Id = Guid.NewGuid(), Language = "tr", LanguageName = "Turkce", Version = "1.0",
                TemplateContent = @"<div style=""font-family:'Segoe UI',Arial,sans-serif;max-width:700px;margin:0 auto;padding:32px;border:2px solid #1a1a2e;border-radius:12px"">
<div style=""text-align:center;border-bottom:3px double #1a1a2e;padding-bottom:16px;margin-bottom:24px"">
<h1 style=""margin:0;color:#1a1a2e;font-size:28px"">YETKI BELGESI (FULLMAKT)</h1>
<p style=""margin:4px 0 0;color:#666;font-size:13px"">Isvec Sozlesme Kanunu (Lag om avtal, 1915:218) 2. Bolum</p>
</div>
<table style=""width:100%;margin-bottom:20px;font-size:14px""><tr><td><strong>Belge No:</strong> {{VerificationCode}}</td><td style=""text-align:right""><strong>Tarih:</strong> {{CreatedAt}}</td></tr><tr><td><strong>Versiyon:</strong> {{DocumentVersion}}</td><td style=""text-align:right""></td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">1. TARAFLAR</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px"">
<tr><td style=""width:50%;padding:8px;background:#f8f9fa;border-radius:6px""><strong>Yetki Veren (Fullmaktsgivare)</strong><br/>Ad Soyad: {{GrantorName}}<br/>Kisisel No: {{GrantorPersonalNumber}}</td>
<td style=""width:50%;padding:8px;background:#f0f4ff;border-radius:6px""><strong>Yetki Alan (Ombud)</strong><br/>Ad Soyad: {{DelegateName}}<br/>Kisisel No: {{DelegatePersonalNumber}}</td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">2. KURUM VE HIZMET BILGILERI</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px""><tr><td style=""padding:4px 0""><strong>Kurum Adi:</strong> {{OrganizationName}}</td></tr><tr><td style=""padding:4px 0""><strong>Kurum Numarasi:</strong> {{OrganizationNumber}}</td></tr><tr><td style=""padding:4px 0""><strong>Verilen Yetkiler:</strong> {{Operations}}</td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">3. GECERLILIK SURESI</h2>
<p style=""font-size:14px""><strong>Baslangic:</strong> {{ValidFrom}} &mdash; <strong>Bitis:</strong> {{ValidTo}}</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">4. YETKI KAPSAMI</h2>
<p style=""font-size:14px"">Yukarida belirtilen yetki veren, yetki alan kisiyi <strong>{{OrganizationName}}</strong> nezdinde asagidaki islemleri kendi adina ve hesabina yapma konusunda yetkilendirmistir: <strong>{{Operations}}</strong></p>
<p style=""font-size:14px""><strong>Notlar:</strong> {{Notes}}</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">5. YASAL DAYANAK</h2>
<p style=""font-size:13px;color:#555"">Bu yetki belgesi, Isvec Sozlesme Kanunu (Lag om avtal, 1915:218) 2. Bolum hukumlerine uygun olarak duzenlenmistir. Yetki veren, bu belge ile verilen yetkileri herhangi bir zamanda tek tarafli olarak geri alabilir.</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">6. IMZALAR</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px"">
<tr><td style=""width:50%;padding:16px;border:1px dashed #ccc;border-radius:6px;text-align:center"">Yetki Veren<br/><br/><strong>{{GrantorName}}</strong><br/><em>BankID ile elektronik imza</em></td>
<td style=""width:50%;padding:16px;border:1px dashed #ccc;border-radius:6px;text-align:center"">Yetki Alan<br/><br/><strong>{{DelegateName}}</strong><br/><em>BankID ile elektronik imza</em></td></tr></table>

<div style=""text-align:center;padding:16px;background:#f8f9fa;border-radius:8px;margin-top:20px"">
<p style=""margin:0;font-size:14px""><strong>Dogrulama Kodu:</strong> {{VerificationCode}}</p>
<p style=""margin:4px 0 0;font-size:12px;color:#888"">Bu belgeyi dogrulamak icin QR kodu okutun veya dogrulama kodunu girin</p>
</div>
<p style=""text-align:center;margin-top:16px;font-size:12px;color:#aaa"">Minion — Yetkilendirme Yonetim Platformu</p>
</div>"
            },

            // ── English ──
            new()
            {
                Id = Guid.NewGuid(), Language = "en", LanguageName = "English", Version = "1.0",
                TemplateContent = @"<div style=""font-family:'Segoe UI',Arial,sans-serif;max-width:700px;margin:0 auto;padding:32px;border:2px solid #1a1a2e;border-radius:12px"">
<div style=""text-align:center;border-bottom:3px double #1a1a2e;padding-bottom:16px;margin-bottom:24px"">
<h1 style=""margin:0;color:#1a1a2e;font-size:28px"">POWER OF ATTORNEY (FULLMAKT)</h1>
<p style=""margin:4px 0 0;color:#666;font-size:13px"">Swedish Contracts Act (Lag om avtal, 1915:218) Chapter 2</p>
</div>
<table style=""width:100%;margin-bottom:20px;font-size:14px""><tr><td><strong>Document No:</strong> {{VerificationCode}}</td><td style=""text-align:right""><strong>Date:</strong> {{CreatedAt}}</td></tr><tr><td><strong>Version:</strong> {{DocumentVersion}}</td><td style=""text-align:right""></td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">1. PARTIES</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px"">
<tr><td style=""width:50%;padding:8px;background:#f8f9fa;border-radius:6px""><strong>Principal (Fullmaktsgivare)</strong><br/>Name: {{GrantorName}}<br/>Personal No: {{GrantorPersonalNumber}}</td>
<td style=""width:50%;padding:8px;background:#f0f4ff;border-radius:6px""><strong>Agent (Ombud)</strong><br/>Name: {{DelegateName}}<br/>Personal No: {{DelegatePersonalNumber}}</td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">2. ORGANIZATION AND SERVICES</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px""><tr><td style=""padding:4px 0""><strong>Organization:</strong> {{OrganizationName}}</td></tr><tr><td style=""padding:4px 0""><strong>Org Number:</strong> {{OrganizationNumber}}</td></tr><tr><td style=""padding:4px 0""><strong>Authorized Operations:</strong> {{Operations}}</td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">3. VALIDITY PERIOD</h2>
<p style=""font-size:14px""><strong>From:</strong> {{ValidFrom}} &mdash; <strong>To:</strong> {{ValidTo}}</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">4. SCOPE OF AUTHORITY</h2>
<p style=""font-size:14px"">The above-named principal hereby authorizes the agent to act on their behalf at <strong>{{OrganizationName}}</strong> for the following operations: <strong>{{Operations}}</strong></p>
<p style=""font-size:14px""><strong>Notes:</strong> {{Notes}}</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">5. LEGAL BASIS</h2>
<p style=""font-size:13px;color:#555"">This power of attorney is issued in accordance with Chapter 2 of the Swedish Contracts Act (Lag om avtal, 1915:218). The principal may unilaterally revoke this authorization at any time.</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">6. SIGNATURES</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px"">
<tr><td style=""width:50%;padding:16px;border:1px dashed #ccc;border-radius:6px;text-align:center"">Principal<br/><br/><strong>{{GrantorName}}</strong><br/><em>Electronic signature via BankID</em></td>
<td style=""width:50%;padding:16px;border:1px dashed #ccc;border-radius:6px;text-align:center"">Agent<br/><br/><strong>{{DelegateName}}</strong><br/><em>Electronic signature via BankID</em></td></tr></table>

<div style=""text-align:center;padding:16px;background:#f8f9fa;border-radius:8px;margin-top:20px"">
<p style=""margin:0;font-size:14px""><strong>Verification Code:</strong> {{VerificationCode}}</p>
<p style=""margin:4px 0 0;font-size:12px;color:#888"">Scan the QR code or enter the verification code to verify this document</p>
</div>
<p style=""text-align:center;margin-top:16px;font-size:12px;color:#aaa"">Minion — Authorization Management Platform</p>
</div>"
            },

            // ── Swedish ──
            new()
            {
                Id = Guid.NewGuid(), Language = "sv", LanguageName = "Svenska", Version = "1.0",
                TemplateContent = @"<div style=""font-family:'Segoe UI',Arial,sans-serif;max-width:700px;margin:0 auto;padding:32px;border:2px solid #1a1a2e;border-radius:12px"">
<div style=""text-align:center;border-bottom:3px double #1a1a2e;padding-bottom:16px;margin-bottom:24px"">
<h1 style=""margin:0;color:#1a1a2e;font-size:28px"">FULLMAKT</h1>
<p style=""margin:4px 0 0;color:#666;font-size:13px"">Avtalslagen (1915:218) 2 kap.</p>
</div>
<table style=""width:100%;margin-bottom:20px;font-size:14px""><tr><td><strong>Dokumentnr:</strong> {{VerificationCode}}</td><td style=""text-align:right""><strong>Datum:</strong> {{CreatedAt}}</td></tr><tr><td><strong>Version:</strong> {{DocumentVersion}}</td><td style=""text-align:right""></td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">1. PARTER</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px"">
<tr><td style=""width:50%;padding:8px;background:#f8f9fa;border-radius:6px""><strong>Fullmaktsgivare</strong><br/>Namn: {{GrantorName}}<br/>Personnr: {{GrantorPersonalNumber}}</td>
<td style=""width:50%;padding:8px;background:#f0f4ff;border-radius:6px""><strong>Ombud (Fullmaktstagare)</strong><br/>Namn: {{DelegateName}}<br/>Personnr: {{DelegatePersonalNumber}}</td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">2. ORGANISATION OCH TJANSTER</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px""><tr><td style=""padding:4px 0""><strong>Organisation:</strong> {{OrganizationName}}</td></tr><tr><td style=""padding:4px 0""><strong>Orgnr:</strong> {{OrganizationNumber}}</td></tr><tr><td style=""padding:4px 0""><strong>Behorighet:</strong> {{Operations}}</td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">3. GILTIGHETSTID</h2>
<p style=""font-size:14px""><strong>Fran:</strong> {{ValidFrom}} &mdash; <strong>Till:</strong> {{ValidTo}}</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">4. BEHORIGHETENS OMFATTNING</h2>
<p style=""font-size:14px"">Ovanstaende fullmaktsgivare bemyndigar harmed ombudet att pa sina vagnar utfora foljande arenden hos <strong>{{OrganizationName}}</strong>: <strong>{{Operations}}</strong></p>
<p style=""font-size:14px""><strong>Anmarkningar:</strong> {{Notes}}</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">5. RATTSLIG GRUND</h2>
<p style=""font-size:13px;color:#555"">Denna fullmakt ar upprattad i enlighet med 2 kap. avtalslagen (1915:218). Fullmaktsgivaren kan ensidigt aterkalla denna fullmakt nar som helst.</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">6. UNDERSKRIFTER</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px"">
<tr><td style=""width:50%;padding:16px;border:1px dashed #ccc;border-radius:6px;text-align:center"">Fullmaktsgivare<br/><br/><strong>{{GrantorName}}</strong><br/><em>Elektronisk signatur via BankID</em></td>
<td style=""width:50%;padding:16px;border:1px dashed #ccc;border-radius:6px;text-align:center"">Ombud<br/><br/><strong>{{DelegateName}}</strong><br/><em>Elektronisk signatur via BankID</em></td></tr></table>

<div style=""text-align:center;padding:16px;background:#f8f9fa;border-radius:8px;margin-top:20px"">
<p style=""margin:0;font-size:14px""><strong>Verifieringskod:</strong> {{VerificationCode}}</p>
<p style=""margin:4px 0 0;font-size:12px;color:#888"">Skanna QR-koden eller ange verifieringskoden for att verifiera detta dokument</p>
</div>
<p style=""text-align:center;margin-top:16px;font-size:12px;color:#aaa"">Minion — Behorighetssystem</p>
</div>"
            },

            // ── German ──
            new()
            {
                Id = Guid.NewGuid(), Language = "de", LanguageName = "Deutsch", Version = "1.0",
                TemplateContent = @"<div style=""font-family:'Segoe UI',Arial,sans-serif;max-width:700px;margin:0 auto;padding:32px;border:2px solid #1a1a2e;border-radius:12px"">
<div style=""text-align:center;border-bottom:3px double #1a1a2e;padding-bottom:16px;margin-bottom:24px"">
<h1 style=""margin:0;color:#1a1a2e;font-size:28px"">VOLLMACHT (FULLMAKT)</h1>
<p style=""margin:4px 0 0;color:#666;font-size:13px"">Schwedisches Vertragsgesetz (Lag om avtal, 1915:218) Kapitel 2</p>
</div>
<table style=""width:100%;margin-bottom:20px;font-size:14px""><tr><td><strong>Dokumentnr:</strong> {{VerificationCode}}</td><td style=""text-align:right""><strong>Datum:</strong> {{CreatedAt}}</td></tr><tr><td><strong>Version:</strong> {{DocumentVersion}}</td><td style=""text-align:right""></td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">1. PARTEIEN</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px"">
<tr><td style=""width:50%;padding:8px;background:#f8f9fa;border-radius:6px""><strong>Vollmachtgeber (Fullmaktsgivare)</strong><br/>Name: {{GrantorName}}<br/>Personennr: {{GrantorPersonalNumber}}</td>
<td style=""width:50%;padding:8px;background:#f0f4ff;border-radius:6px""><strong>Bevollmachtigter (Ombud)</strong><br/>Name: {{DelegateName}}<br/>Personennr: {{DelegatePersonalNumber}}</td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">2. ORGANISATION UND DIENSTLEISTUNGEN</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px""><tr><td style=""padding:4px 0""><strong>Organisation:</strong> {{OrganizationName}}</td></tr><tr><td style=""padding:4px 0""><strong>Orgnr:</strong> {{OrganizationNumber}}</td></tr><tr><td style=""padding:4px 0""><strong>Befugnisse:</strong> {{Operations}}</td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">3. GULTIGKEITSZEITRAUM</h2>
<p style=""font-size:14px""><strong>Von:</strong> {{ValidFrom}} &mdash; <strong>Bis:</strong> {{ValidTo}}</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">4. UMFANG DER VOLLMACHT</h2>
<p style=""font-size:14px"">Der oben genannte Vollmachtgeber bevollmachtigt hiermit den Bevollmachtigten, in seinem Namen bei <strong>{{OrganizationName}}</strong> folgende Handlungen vorzunehmen: <strong>{{Operations}}</strong></p>
<p style=""font-size:14px""><strong>Anmerkungen:</strong> {{Notes}}</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">5. RECHTSGRUNDLAGE</h2>
<p style=""font-size:13px;color:#555"">Diese Vollmacht wurde gemaess Kapitel 2 des schwedischen Vertragsgesetzes (Lag om avtal, 1915:218) ausgestellt. Der Vollmachtgeber kann diese Vollmacht jederzeit einseitig widerrufen.</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">6. UNTERSCHRIFTEN</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px"">
<tr><td style=""width:50%;padding:16px;border:1px dashed #ccc;border-radius:6px;text-align:center"">Vollmachtgeber<br/><br/><strong>{{GrantorName}}</strong><br/><em>Elektronische Signatur via BankID</em></td>
<td style=""width:50%;padding:16px;border:1px dashed #ccc;border-radius:6px;text-align:center"">Bevollmachtigter<br/><br/><strong>{{DelegateName}}</strong><br/><em>Elektronische Signatur via BankID</em></td></tr></table>

<div style=""text-align:center;padding:16px;background:#f8f9fa;border-radius:8px;margin-top:20px"">
<p style=""margin:0;font-size:14px""><strong>Verifizierungscode:</strong> {{VerificationCode}}</p>
<p style=""margin:4px 0 0;font-size:12px;color:#888"">Scannen Sie den QR-Code oder geben Sie den Verifizierungscode ein</p>
</div>
<p style=""text-align:center;margin-top:16px;font-size:12px;color:#aaa"">Minion — Berechtigungsverwaltung</p>
</div>"
            },

            // ── Spanish ──
            new()
            {
                Id = Guid.NewGuid(), Language = "es", LanguageName = "Espanol", Version = "1.0",
                TemplateContent = @"<div style=""font-family:'Segoe UI',Arial,sans-serif;max-width:700px;margin:0 auto;padding:32px;border:2px solid #1a1a2e;border-radius:12px"">
<div style=""text-align:center;border-bottom:3px double #1a1a2e;padding-bottom:16px;margin-bottom:24px"">
<h1 style=""margin:0;color:#1a1a2e;font-size:28px"">PODER NOTARIAL (FULLMAKT)</h1>
<p style=""margin:4px 0 0;color:#666;font-size:13px"">Ley de Contratos de Suecia (Lag om avtal, 1915:218) Capitulo 2</p>
</div>
<table style=""width:100%;margin-bottom:20px;font-size:14px""><tr><td><strong>N.o de Documento:</strong> {{VerificationCode}}</td><td style=""text-align:right""><strong>Fecha:</strong> {{CreatedAt}}</td></tr><tr><td><strong>Version:</strong> {{DocumentVersion}}</td><td style=""text-align:right""></td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">1. PARTES</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px"">
<tr><td style=""width:50%;padding:8px;background:#f8f9fa;border-radius:6px""><strong>Poderdante (Fullmaktsgivare)</strong><br/>Nombre: {{GrantorName}}<br/>N.o Personal: {{GrantorPersonalNumber}}</td>
<td style=""width:50%;padding:8px;background:#f0f4ff;border-radius:6px""><strong>Apoderado (Ombud)</strong><br/>Nombre: {{DelegateName}}<br/>N.o Personal: {{DelegatePersonalNumber}}</td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">2. ORGANIZACION Y SERVICIOS</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px""><tr><td style=""padding:4px 0""><strong>Organizacion:</strong> {{OrganizationName}}</td></tr><tr><td style=""padding:4px 0""><strong>N.o Org:</strong> {{OrganizationNumber}}</td></tr><tr><td style=""padding:4px 0""><strong>Operaciones Autorizadas:</strong> {{Operations}}</td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">3. PERIODO DE VALIDEZ</h2>
<p style=""font-size:14px""><strong>Desde:</strong> {{ValidFrom}} &mdash; <strong>Hasta:</strong> {{ValidTo}}</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">4. ALCANCE DE LA AUTORIZACION</h2>
<p style=""font-size:14px"">El poderdante mencionado autoriza al apoderado a actuar en su nombre ante <strong>{{OrganizationName}}</strong> para las siguientes operaciones: <strong>{{Operations}}</strong></p>
<p style=""font-size:14px""><strong>Notas:</strong> {{Notes}}</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">5. BASE LEGAL</h2>
<p style=""font-size:13px;color:#555"">Este poder notarial se emite de conformidad con el Capitulo 2 de la Ley de Contratos de Suecia (Lag om avtal, 1915:218). El poderdante puede revocar unilateralmente esta autorizacion en cualquier momento.</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">6. FIRMAS</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px"">
<tr><td style=""width:50%;padding:16px;border:1px dashed #ccc;border-radius:6px;text-align:center"">Poderdante<br/><br/><strong>{{GrantorName}}</strong><br/><em>Firma electronica via BankID</em></td>
<td style=""width:50%;padding:16px;border:1px dashed #ccc;border-radius:6px;text-align:center"">Apoderado<br/><br/><strong>{{DelegateName}}</strong><br/><em>Firma electronica via BankID</em></td></tr></table>

<div style=""text-align:center;padding:16px;background:#f8f9fa;border-radius:8px;margin-top:20px"">
<p style=""margin:0;font-size:14px""><strong>Codigo de Verificacion:</strong> {{VerificationCode}}</p>
<p style=""margin:4px 0 0;font-size:12px;color:#888"">Escanee el codigo QR o ingrese el codigo de verificacion</p>
</div>
<p style=""text-align:center;margin-top:16px;font-size:12px;color:#aaa"">Minion — Plataforma de Gestion de Autorizaciones</p>
</div>"
            },

            // ── French ──
            new()
            {
                Id = Guid.NewGuid(), Language = "fr", LanguageName = "Francais", Version = "1.0",
                TemplateContent = @"<div style=""font-family:'Segoe UI',Arial,sans-serif;max-width:700px;margin:0 auto;padding:32px;border:2px solid #1a1a2e;border-radius:12px"">
<div style=""text-align:center;border-bottom:3px double #1a1a2e;padding-bottom:16px;margin-bottom:24px"">
<h1 style=""margin:0;color:#1a1a2e;font-size:28px"">PROCURATION (FULLMAKT)</h1>
<p style=""margin:4px 0 0;color:#666;font-size:13px"">Loi suedoise sur les contrats (Lag om avtal, 1915:218) Chapitre 2</p>
</div>
<table style=""width:100%;margin-bottom:20px;font-size:14px""><tr><td><strong>N.o de Document:</strong> {{VerificationCode}}</td><td style=""text-align:right""><strong>Date:</strong> {{CreatedAt}}</td></tr><tr><td><strong>Version:</strong> {{DocumentVersion}}</td><td style=""text-align:right""></td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">1. PARTIES</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px"">
<tr><td style=""width:50%;padding:8px;background:#f8f9fa;border-radius:6px""><strong>Mandant (Fullmaktsgivare)</strong><br/>Nom: {{GrantorName}}<br/>N.o Personnel: {{GrantorPersonalNumber}}</td>
<td style=""width:50%;padding:8px;background:#f0f4ff;border-radius:6px""><strong>Mandataire (Ombud)</strong><br/>Nom: {{DelegateName}}<br/>N.o Personnel: {{DelegatePersonalNumber}}</td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">2. ORGANISATION ET SERVICES</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px""><tr><td style=""padding:4px 0""><strong>Organisation:</strong> {{OrganizationName}}</td></tr><tr><td style=""padding:4px 0""><strong>N.o Org:</strong> {{OrganizationNumber}}</td></tr><tr><td style=""padding:4px 0""><strong>Operations Autorisees:</strong> {{Operations}}</td></tr></table>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">3. PERIODE DE VALIDITE</h2>
<p style=""font-size:14px""><strong>Du:</strong> {{ValidFrom}} &mdash; <strong>Au:</strong> {{ValidTo}}</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">4. ETENDUE DE L'AUTORISATION</h2>
<p style=""font-size:14px"">Le mandant susnomme autorise par la presente le mandataire a agir en son nom aupres de <strong>{{OrganizationName}}</strong> pour les operations suivantes: <strong>{{Operations}}</strong></p>
<p style=""font-size:14px""><strong>Notes:</strong> {{Notes}}</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">5. BASE JURIDIQUE</h2>
<p style=""font-size:13px;color:#555"">Cette procuration est etablie conformement au Chapitre 2 de la Loi suedoise sur les contrats (Lag om avtal, 1915:218). Le mandant peut revoquer unilateralement cette autorisation a tout moment.</p>

<h2 style=""color:#1a1a2e;font-size:18px;border-bottom:1px solid #ddd;padding-bottom:8px"">6. SIGNATURES</h2>
<table style=""width:100%;margin-bottom:20px;font-size:14px"">
<tr><td style=""width:50%;padding:16px;border:1px dashed #ccc;border-radius:6px;text-align:center"">Mandant<br/><br/><strong>{{GrantorName}}</strong><br/><em>Signature electronique via BankID</em></td>
<td style=""width:50%;padding:16px;border:1px dashed #ccc;border-radius:6px;text-align:center"">Mandataire<br/><br/><strong>{{DelegateName}}</strong><br/><em>Signature electronique via BankID</em></td></tr></table>

<div style=""text-align:center;padding:16px;background:#f8f9fa;border-radius:8px;margin-top:20px"">
<p style=""margin:0;font-size:14px""><strong>Code de Verification:</strong> {{VerificationCode}}</p>
<p style=""margin:4px 0 0;font-size:12px;color:#888"">Scannez le code QR ou entrez le code de verification</p>
</div>
<p style=""text-align:center;margin-top:16px;font-size:12px;color:#aaa"">Minion — Plateforme de Gestion des Autorisations</p>
</div>"
            }
        };

        context.DelegationDocumentTemplates.AddRange(templates);
        await context.SaveChangesAsync();
    }
}

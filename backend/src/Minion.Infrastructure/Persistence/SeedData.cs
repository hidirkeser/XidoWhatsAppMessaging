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
}

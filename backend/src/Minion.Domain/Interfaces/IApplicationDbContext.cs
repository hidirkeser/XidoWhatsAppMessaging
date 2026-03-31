using Microsoft.EntityFrameworkCore;
using Minion.Domain.Entities;

namespace Minion.Domain.Interfaces;

public interface IApplicationDbContext
{
    DbSet<User> Users { get; }
    DbSet<Organization> Organizations { get; }
    DbSet<UserOrganization> UserOrganizations { get; }
    DbSet<OperationType> OperationTypes { get; }
    DbSet<Delegation> Delegations { get; }
    DbSet<DelegationOperation> DelegationOperations { get; }
    DbSet<CreditPackage> CreditPackages { get; }
    DbSet<UserCredit> UserCredits { get; }
    DbSet<CreditTransaction> CreditTransactions { get; }
    DbSet<Notification> Notifications { get; }
    DbSet<DeviceToken> DeviceTokens { get; }
    DbSet<AuditLog> AuditLogs { get; }
    DbSet<PaymentTransaction> PaymentTransactions { get; }
    DbSet<DelegationVerificationLog> DelegationVerificationLogs { get; }
    DbSet<UserNotificationPreference> UserNotificationPreferences { get; }
    DbSet<Product> Products { get; }
    DbSet<UserSubscription> UserSubscriptions { get; }
    DbSet<CorporateApplication> CorporateApplications { get; }
    DbSet<CorporateOtp> CorporateOtps { get; }
    DbSet<OrganizationApiKey> OrganizationApiKeys { get; }
    DbSet<DelegationDocument> DelegationDocuments { get; }
    DbSet<DelegationDocumentTemplate> DelegationDocumentTemplates { get; }
    DbSet<DelegationDocumentLog> DelegationDocumentLogs { get; }
    DbSet<WebProduct> WebProducts { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}

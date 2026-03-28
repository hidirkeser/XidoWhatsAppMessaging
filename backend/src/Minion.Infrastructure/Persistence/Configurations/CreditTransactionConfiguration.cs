using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class CreditTransactionConfiguration : IEntityTypeConfiguration<CreditTransaction>
{
    public void Configure(EntityTypeBuilder<CreditTransaction> builder)
    {
        builder.HasKey(ct => ct.Id);
        builder.Property(ct => ct.Id).HasDefaultValueSql("gen_random_uuid()");
        builder.Property(ct => ct.TransactionType).HasConversion<string>().HasMaxLength(20);
        builder.Property(ct => ct.Description).HasMaxLength(500);
        builder.HasIndex(ct => new { ct.UserId, ct.CreatedAt }).IsDescending(false, true);

        builder.HasOne(ct => ct.User)
            .WithMany(u => u.CreditTransactions)
            .HasForeignKey(ct => ct.UserId)
            .OnDelete(DeleteBehavior.NoAction);

        builder.HasOne(ct => ct.Delegation)
            .WithMany()
            .HasForeignKey(ct => ct.DelegationId)
            .OnDelete(DeleteBehavior.NoAction);

        builder.HasOne(ct => ct.CreditPackage)
            .WithMany()
            .HasForeignKey(ct => ct.CreditPackageId)
            .OnDelete(DeleteBehavior.NoAction);

        builder.HasOne(ct => ct.CreatedByUser)
            .WithMany()
            .HasForeignKey(ct => ct.CreatedByUserId)
            .OnDelete(DeleteBehavior.NoAction);
    }
}

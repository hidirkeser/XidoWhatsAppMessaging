using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class PaymentTransactionConfiguration : IEntityTypeConfiguration<PaymentTransaction>
{
    public void Configure(EntityTypeBuilder<PaymentTransaction> builder)
    {
        builder.HasKey(pt => pt.Id);
        builder.Property(pt => pt.Id).HasDefaultValueSql("gen_random_uuid()");
        builder.Property(pt => pt.Provider).HasConversion<string>().HasMaxLength(20);
        builder.Property(pt => pt.Status).HasConversion<string>().HasMaxLength(20);
        builder.Property(pt => pt.AmountSEK).HasPrecision(10, 2);
        builder.Property(pt => pt.ExternalPaymentId).HasMaxLength(200);
        builder.Property(pt => pt.ExternalOrderRef).HasMaxLength(200);
        builder.HasIndex(pt => pt.ExternalPaymentId);
        builder.HasIndex(pt => new { pt.UserId, pt.CreatedAt }).IsDescending(false, true);

        builder.HasOne(pt => pt.User).WithMany().HasForeignKey(pt => pt.UserId).OnDelete(DeleteBehavior.NoAction);
        builder.HasOne(pt => pt.CreditPackage).WithMany().HasForeignKey(pt => pt.CreditPackageId).OnDelete(DeleteBehavior.NoAction);
    }
}

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class CreditPackageConfiguration : IEntityTypeConfiguration<CreditPackage>
{
    public void Configure(EntityTypeBuilder<CreditPackage> builder)
    {
        builder.HasKey(cp => cp.Id);
        builder.Property(cp => cp.Id).HasDefaultValueSql("gen_random_uuid()");
        builder.Property(cp => cp.Name).HasMaxLength(100).IsRequired();
        builder.Property(cp => cp.PriceSEK).HasPrecision(10, 2);
        builder.Property(cp => cp.Description).HasMaxLength(500);
    }
}

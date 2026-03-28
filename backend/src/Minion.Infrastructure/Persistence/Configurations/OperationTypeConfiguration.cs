using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class OperationTypeConfiguration : IEntityTypeConfiguration<OperationType>
{
    public void Configure(EntityTypeBuilder<OperationType> builder)
    {
        builder.HasKey(ot => ot.Id);
        builder.Property(ot => ot.Id).HasDefaultValueSql("NEWSEQUENTIALID()");
        builder.Property(ot => ot.Name).HasMaxLength(200).IsRequired();
        builder.Property(ot => ot.Description).HasMaxLength(1000);
        builder.Property(ot => ot.Icon).HasMaxLength(50);
        builder.Property(ot => ot.CreditCost).HasDefaultValue(1);

        builder.HasOne(ot => ot.Organization)
            .WithMany(o => o.OperationTypes)
            .HasForeignKey(ot => ot.OrganizationId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

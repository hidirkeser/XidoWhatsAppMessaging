using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class OrganizationConfiguration : IEntityTypeConfiguration<Organization>
{
    public void Configure(EntityTypeBuilder<Organization> builder)
    {
        builder.HasKey(o => o.Id);
        builder.Property(o => o.Id).HasDefaultValueSql("gen_random_uuid()");
        builder.Property(o => o.Name).HasMaxLength(200).IsRequired();
        builder.Property(o => o.OrgNumber).HasMaxLength(20).IsRequired();
        builder.HasIndex(o => o.OrgNumber).IsUnique();
        builder.Property(o => o.Address).HasMaxLength(500);
        builder.Property(o => o.City).HasMaxLength(100);
        builder.Property(o => o.PostalCode).HasMaxLength(10);
        builder.Property(o => o.ContactEmail).HasMaxLength(256);
        builder.Property(o => o.ContactPhone).HasMaxLength(20);
        builder.HasQueryFilter(o => !o.IsDeleted);

        builder.HasOne(o => o.CreatedByUser)
            .WithMany()
            .HasForeignKey(o => o.CreatedByUserId)
            .OnDelete(DeleteBehavior.NoAction);
    }
}

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class CorporateApplicationConfiguration : IEntityTypeConfiguration<CorporateApplication>
{
    public void Configure(EntityTypeBuilder<CorporateApplication> builder)
    {
        builder.HasKey(a => a.Id);
        builder.Property(a => a.Id).HasDefaultValueSql("gen_random_uuid()");
        builder.Property(a => a.CompanyName).HasMaxLength(200).IsRequired();
        builder.Property(a => a.OrgNumber).HasMaxLength(20).IsRequired();
        builder.Property(a => a.ContactName).HasMaxLength(200).IsRequired();
        builder.Property(a => a.ContactEmail).HasMaxLength(256).IsRequired();
        builder.Property(a => a.ContactPhone).HasMaxLength(20);
        builder.Property(a => a.DocumentPaths).HasColumnType("jsonb");
        builder.Property(a => a.Status).HasConversion<string>().HasMaxLength(20);
        builder.Property(a => a.ReviewNote).HasMaxLength(1000);

        builder.HasOne(a => a.ReviewedByUser)
            .WithMany()
            .HasForeignKey(a => a.ReviewedByUserId)
            .OnDelete(DeleteBehavior.NoAction);

        builder.HasIndex(a => a.Status);
        builder.HasIndex(a => a.OrgNumber);
    }
}

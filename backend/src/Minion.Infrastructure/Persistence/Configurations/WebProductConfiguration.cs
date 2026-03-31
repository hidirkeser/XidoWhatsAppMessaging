using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class WebProductConfiguration : IEntityTypeConfiguration<WebProduct>
{
    public void Configure(EntityTypeBuilder<WebProduct> builder)
    {
        builder.HasKey(wp => wp.Id);
        builder.Property(wp => wp.Id).HasDefaultValueSql("gen_random_uuid()");
        builder.Property(wp => wp.Slug).HasMaxLength(100).IsRequired();
        builder.HasIndex(wp => wp.Slug).IsUnique();
        builder.Property(wp => wp.Icon).HasMaxLength(50).IsRequired();
        builder.Property(wp => wp.Color).HasMaxLength(20).IsRequired();
        builder.Property(wp => wp.NameEn).HasMaxLength(200).IsRequired();
        builder.Property(wp => wp.DescriptionEn).HasMaxLength(1000).IsRequired();
        builder.Property(wp => wp.FeaturesEn).HasColumnType("jsonb");
        builder.Property(wp => wp.NameSv).HasMaxLength(200).IsRequired();
        builder.Property(wp => wp.DescriptionSv).HasMaxLength(1000).IsRequired();
        builder.Property(wp => wp.FeaturesSv).HasColumnType("jsonb");
    }
}

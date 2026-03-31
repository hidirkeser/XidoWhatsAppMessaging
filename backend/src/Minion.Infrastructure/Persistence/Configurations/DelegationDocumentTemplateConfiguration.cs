using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class DelegationDocumentTemplateConfiguration : IEntityTypeConfiguration<DelegationDocumentTemplate>
{
    public void Configure(EntityTypeBuilder<DelegationDocumentTemplate> builder)
    {
        builder.HasKey(t => t.Id);
        builder.Property(t => t.Id).HasDefaultValueSql("gen_random_uuid()");

        builder.Property(t => t.Language).HasMaxLength(5).IsRequired();
        builder.Property(t => t.LanguageName).HasMaxLength(50).IsRequired();
        builder.Property(t => t.TemplateContent).IsRequired();
        builder.Property(t => t.Version).HasMaxLength(10).IsRequired();

        builder.HasIndex(t => new { t.Language, t.IsActive })
            .HasFilter("\"IsActive\" = true")
            .IsUnique();
    }
}

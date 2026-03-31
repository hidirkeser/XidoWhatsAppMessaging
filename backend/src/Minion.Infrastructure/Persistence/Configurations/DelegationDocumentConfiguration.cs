using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;
using Minion.Domain.Enums;

namespace Minion.Infrastructure.Persistence.Configurations;

public class DelegationDocumentConfiguration : IEntityTypeConfiguration<DelegationDocument>
{
    public void Configure(EntityTypeBuilder<DelegationDocument> builder)
    {
        builder.HasKey(d => d.Id);
        builder.Property(d => d.Id).HasDefaultValueSql("gen_random_uuid()");

        builder.Property(d => d.Language).HasMaxLength(5).IsRequired();
        builder.Property(d => d.RenderedContent).IsRequired();
        builder.Property(d => d.DocumentVersion).HasMaxLength(10).IsRequired();
        builder.Property(d => d.Status)
            .HasConversion<string>()
            .HasMaxLength(30)
            .HasDefaultValue(DocumentStatus.Draft);

        builder.Property(d => d.QrCodeData).HasMaxLength(500);

        builder.HasIndex(d => d.DelegationId).IsUnique();
        builder.HasIndex(d => d.Status);

        builder.HasOne(d => d.Delegation)
            .WithOne(del => del.Document)
            .HasForeignKey<DelegationDocument>(d => d.DelegationId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

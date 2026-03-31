using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;
using Minion.Domain.Enums;

namespace Minion.Infrastructure.Persistence.Configurations;

public class DelegationDocumentLogConfiguration : IEntityTypeConfiguration<DelegationDocumentLog>
{
    public void Configure(EntityTypeBuilder<DelegationDocumentLog> builder)
    {
        builder.HasKey(l => l.Id);
        builder.Property(l => l.Id).HasDefaultValueSql("gen_random_uuid()");

        builder.Property(l => l.ActorName).HasMaxLength(200);
        builder.Property(l => l.Action)
            .HasConversion<string>()
            .HasMaxLength(30)
            .IsRequired();
        builder.Property(l => l.IpAddress).HasMaxLength(45);

        builder.HasIndex(l => l.DelegationDocumentId);
        builder.HasIndex(l => l.Timestamp).IsDescending();
        builder.HasIndex(l => new { l.ActorUserId, l.Timestamp }).IsDescending(false, true);

        builder.HasOne(l => l.DelegationDocument)
            .WithMany(d => d.Logs)
            .HasForeignKey(l => l.DelegationDocumentId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

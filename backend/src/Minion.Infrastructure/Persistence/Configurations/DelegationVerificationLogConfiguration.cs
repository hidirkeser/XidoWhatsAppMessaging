using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class DelegationVerificationLogConfiguration : IEntityTypeConfiguration<DelegationVerificationLog>
{
    public void Configure(EntityTypeBuilder<DelegationVerificationLog> builder)
    {
        builder.HasKey(l => l.Id);
        builder.Property(l => l.Id).HasDefaultValueSql("gen_random_uuid()");
        builder.Property(l => l.VerifierPersonalNumber).HasMaxLength(12).IsRequired();
        builder.Property(l => l.VerifierFullName).HasMaxLength(200).IsRequired();
        builder.Property(l => l.BankIdSignature).HasMaxLength(2000);
        builder.Property(l => l.Channel).HasMaxLength(10);
        builder.Property(l => l.IpAddress).HasMaxLength(45);

        builder.HasOne(l => l.Delegation)
            .WithMany(d => d.VerificationLogs)
            .HasForeignKey(l => l.DelegationId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(l => l.DelegationId);
    }
}

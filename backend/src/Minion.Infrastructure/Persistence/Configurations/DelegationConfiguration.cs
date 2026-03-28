using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;
using Minion.Domain.Enums;

namespace Minion.Infrastructure.Persistence.Configurations;

public class DelegationConfiguration : IEntityTypeConfiguration<Delegation>
{
    public void Configure(EntityTypeBuilder<Delegation> builder)
    {
        builder.HasKey(d => d.Id);
        builder.Property(d => d.Id).HasDefaultValueSql("gen_random_uuid()");
        builder.Property(d => d.Status)
            .HasConversion<string>()
            .HasMaxLength(20)
            .HasDefaultValue(DelegationStatus.PendingApproval);
        builder.Property(d => d.BankIdOrderRef).HasMaxLength(100);
        builder.Property(d => d.Notes).HasMaxLength(1000);

        builder.HasIndex(d => new { d.GrantorUserId, d.Status });
        builder.HasIndex(d => new { d.DelegateUserId, d.Status });
        builder.HasIndex(d => new { d.ValidTo, d.Status })
            .HasFilter("[Status] = 'Active'");

        builder.HasOne(d => d.GrantorUser)
            .WithMany(u => u.GrantedDelegations)
            .HasForeignKey(d => d.GrantorUserId)
            .OnDelete(DeleteBehavior.NoAction);

        builder.HasOne(d => d.DelegateUser)
            .WithMany(u => u.ReceivedDelegations)
            .HasForeignKey(d => d.DelegateUserId)
            .OnDelete(DeleteBehavior.NoAction);

        builder.HasOne(d => d.Organization)
            .WithMany(o => o.Delegations)
            .HasForeignKey(d => d.OrganizationId)
            .OnDelete(DeleteBehavior.NoAction);
    }
}

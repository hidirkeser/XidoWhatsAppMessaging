using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class AuditLogConfiguration : IEntityTypeConfiguration<AuditLog>
{
    public void Configure(EntityTypeBuilder<AuditLog> builder)
    {
        builder.HasKey(al => al.Id);
        builder.Property(al => al.Id).HasDefaultValueSql("NEWSEQUENTIALID()");
        builder.Property(al => al.Action).HasConversion<string>().HasMaxLength(50);
        builder.Property(al => al.ActorName).HasMaxLength(200);
        builder.Property(al => al.IpAddress).HasMaxLength(45);
        builder.Property(al => al.UserAgent).HasMaxLength(500);
        builder.Property(al => al.DeviceInfo).HasMaxLength(500);
        builder.HasIndex(al => al.Timestamp).IsDescending(true);
        builder.HasIndex(al => new { al.ActorUserId, al.Timestamp }).IsDescending(false, true);
        builder.HasIndex(al => new { al.Action, al.Timestamp }).IsDescending(false, true);

        builder.HasOne(al => al.ActorUser).WithMany().HasForeignKey(al => al.ActorUserId).OnDelete(DeleteBehavior.NoAction);
        builder.HasOne(al => al.TargetUser).WithMany().HasForeignKey(al => al.TargetUserId).OnDelete(DeleteBehavior.NoAction);
        builder.HasOne(al => al.Organization).WithMany().HasForeignKey(al => al.OrganizationId).OnDelete(DeleteBehavior.NoAction);
        builder.HasOne(al => al.Delegation).WithMany().HasForeignKey(al => al.DelegationId).OnDelete(DeleteBehavior.NoAction);
    }
}

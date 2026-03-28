using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class UserOrganizationConfiguration : IEntityTypeConfiguration<UserOrganization>
{
    public void Configure(EntityTypeBuilder<UserOrganization> builder)
    {
        builder.HasKey(uo => uo.Id);
        builder.Property(uo => uo.Id).HasDefaultValueSql("gen_random_uuid()");
        builder.Property(uo => uo.Role).HasMaxLength(50).HasDefaultValue("Member");
        builder.HasIndex(uo => new { uo.UserId, uo.OrganizationId }).IsUnique();

        builder.HasOne(uo => uo.User)
            .WithMany(u => u.UserOrganizations)
            .HasForeignKey(uo => uo.UserId)
            .OnDelete(DeleteBehavior.NoAction);

        builder.HasOne(uo => uo.Organization)
            .WithMany(o => o.UserOrganizations)
            .HasForeignKey(uo => uo.OrganizationId)
            .OnDelete(DeleteBehavior.NoAction);

        builder.HasOne(uo => uo.AssignedByUser)
            .WithMany()
            .HasForeignKey(uo => uo.AssignedByUserId)
            .OnDelete(DeleteBehavior.NoAction);
    }
}

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class DeviceTokenConfiguration : IEntityTypeConfiguration<DeviceToken>
{
    public void Configure(EntityTypeBuilder<DeviceToken> builder)
    {
        builder.HasKey(dt => dt.Id);
        builder.Property(dt => dt.Id).HasDefaultValueSql("NEWSEQUENTIALID()");
        builder.Property(dt => dt.Token).HasMaxLength(500).IsRequired();
        builder.HasIndex(dt => dt.Token).IsUnique();
        builder.Property(dt => dt.Platform).HasConversion<string>().HasMaxLength(10);

        builder.HasOne(dt => dt.User)
            .WithMany(u => u.DeviceTokens)
            .HasForeignKey(dt => dt.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

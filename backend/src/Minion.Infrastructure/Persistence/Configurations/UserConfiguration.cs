using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.HasKey(u => u.Id);
        builder.Property(u => u.Id).HasDefaultValueSql("NEWSEQUENTIALID()");
        builder.Property(u => u.PersonalNumber).HasMaxLength(12).IsRequired();
        builder.HasIndex(u => u.PersonalNumber).IsUnique();
        builder.Property(u => u.FirstName).HasMaxLength(100).IsRequired();
        builder.Property(u => u.LastName).HasMaxLength(100).IsRequired();
        builder.Property(u => u.Email).HasMaxLength(256);
        builder.HasIndex(u => u.Email).HasFilter("[Email] IS NOT NULL");
        builder.Property(u => u.Phone).HasMaxLength(20);
        builder.Ignore(u => u.FullName);

        builder.HasOne(u => u.Credit)
            .WithOne(c => c.User)
            .HasForeignKey<UserCredit>(c => c.UserId);
    }
}

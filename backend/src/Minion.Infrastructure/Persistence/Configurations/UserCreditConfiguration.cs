using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class UserCreditConfiguration : IEntityTypeConfiguration<UserCredit>
{
    public void Configure(EntityTypeBuilder<UserCredit> builder)
    {
        builder.HasKey(uc => uc.Id);
        builder.Property(uc => uc.Id).HasDefaultValueSql("gen_random_uuid()");
        builder.HasIndex(uc => uc.UserId).IsUnique();
    }
}

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Minion.Domain.Entities;

namespace Minion.Infrastructure.Persistence.Configurations;

public class DelegationOperationConfiguration : IEntityTypeConfiguration<DelegationOperation>
{
    public void Configure(EntityTypeBuilder<DelegationOperation> builder)
    {
        builder.HasKey(d => d.Id);
        builder.Property(d => d.Id).HasDefaultValueSql("gen_random_uuid()");
        builder.HasIndex(d => new { d.DelegationId, d.OperationTypeId }).IsUnique();

        builder.HasOne(d => d.Delegation)
            .WithMany(del => del.DelegationOperations)
            .HasForeignKey(d => d.DelegationId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(d => d.OperationType)
            .WithMany(ot => ot.DelegationOperations)
            .HasForeignKey(d => d.OperationTypeId)
            .OnDelete(DeleteBehavior.NoAction);
    }
}

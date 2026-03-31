using Microsoft.EntityFrameworkCore;

namespace Xido.WhatsApp.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<MessageLog> MessageLogs => Set<MessageLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<MessageLog>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.RecipientPhone).HasMaxLength(30).IsRequired();
            e.Property(x => x.RecipientName).HasMaxLength(200);
            e.Property(x => x.Body).HasMaxLength(4096);
            e.Property(x => x.Provider).HasMaxLength(50).IsRequired();
            e.Property(x => x.Status).HasMaxLength(50).IsRequired();
            e.Property(x => x.ExternalId).HasMaxLength(200);
            e.Property(x => x.ErrorMessage).HasMaxLength(2000);
            e.HasIndex(x => x.RecipientPhone);
            e.HasIndex(x => x.CreatedAt);
        });
    }
}

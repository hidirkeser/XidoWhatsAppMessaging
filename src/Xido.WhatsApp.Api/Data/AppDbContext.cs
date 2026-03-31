using Microsoft.EntityFrameworkCore;

namespace Xido.WhatsApp.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<MessageLog>    MessageLogs    => Set<MessageLog>();
    public DbSet<InboundMessage> InboundMessages => Set<InboundMessage>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<MessageLog>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.RecipientPhone).HasMaxLength(30).IsRequired();
            e.Property(x => x.RecipientName).HasMaxLength(200);
            e.Property(x => x.Body).HasMaxLength(4096);
            e.Property(x => x.MediaUrl).HasMaxLength(2048);
            e.Property(x => x.Provider).HasMaxLength(50).IsRequired();
            e.Property(x => x.Status).HasMaxLength(50).IsRequired();
            e.Property(x => x.ExternalId).HasMaxLength(200);
            e.Property(x => x.ErrorMessage).HasMaxLength(2000);
            e.HasIndex(x => x.RecipientPhone);
            e.HasIndex(x => x.CreatedAt);
        });

        modelBuilder.Entity<InboundMessage>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.FromPhone).HasMaxLength(30).IsRequired();
            e.Property(x => x.SenderName).HasMaxLength(200);
            e.Property(x => x.Body).HasMaxLength(4096);
            e.Property(x => x.MediaUrl).HasMaxLength(2048);
            e.Property(x => x.MediaType).HasMaxLength(100);
            e.Property(x => x.Provider).HasMaxLength(50).IsRequired();
            e.HasIndex(x => x.FromPhone);
            e.HasIndex(x => x.ReceivedAt);
        });
    }
}

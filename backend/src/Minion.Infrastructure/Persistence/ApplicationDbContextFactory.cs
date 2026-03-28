using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Minion.Infrastructure.Persistence;

/// <summary>
/// Design-time factory used by dotnet-ef CLI to create migrations
/// without requiring a running application or real connection string.
/// </summary>
public class ApplicationDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
{
    public ApplicationDbContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
        optionsBuilder.UseNpgsql(
            "Host=localhost;Port=5432;Database=MinionDb;Username=postgres;Password=postgres",
            b => b.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName));
        return new ApplicationDbContext(optionsBuilder.Options);
    }
}

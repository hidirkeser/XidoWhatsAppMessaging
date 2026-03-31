using Microsoft.EntityFrameworkCore;
using Xido.WhatsApp.Api.Data;
using Xido.WhatsApp.Api.Middleware;
using Xido.WhatsApp.Api.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Xido WhatsApp API", Version = "v1" });
    c.AddSecurityDefinition("ApiKey", new()
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
        In   = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Name = "X-Api-Key",
    });
    c.AddSecurityRequirement(new()
    {
        {
            new() { Reference = new() { Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme, Id = "ApiKey" } },
            []
        }
    });
});

// SQLite
builder.Services.AddDbContext<AppDbContext>(opts =>
    opts.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

// WhatsApp providers
builder.Services.AddHttpClient<AiSensyProvider>();
builder.Services.AddHttpClient<WatiProvider>();
builder.Services.AddScoped<TwilioProvider>();
builder.Services.AddScoped<WhatsAppRouter>();

var app = builder.Build();

// Auto-migrate on startup
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.Migrate();
}

app.UseSwagger();
app.UseSwaggerUI();

app.UseMiddleware<ApiKeyMiddleware>();

app.MapControllers();
app.MapGet("/health", () => Results.Ok(new { status = "healthy", timestamp = DateTime.UtcNow }))
   .AllowAnonymous();

app.Run();

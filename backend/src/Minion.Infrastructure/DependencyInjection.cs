using System.Security.Cryptography.X509Certificates;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Minion.Domain.Interfaces;
using Minion.Infrastructure.Persistence;
using Minion.Infrastructure.BackgroundJobs;
using Minion.Infrastructure.Services;
using Minion.Infrastructure.Services.Payment;

namespace Minion.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseNpgsql(
                configuration.GetConnectionString("DefaultConnection"),
                b => b.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName)));

        services.AddScoped<IApplicationDbContext>(provider =>
            provider.GetRequiredService<ApplicationDbContext>());

        services.AddScoped<IAuditLogService, AuditLogService>();
        services.AddScoped<ICreditService, CreditService>();
        services.AddHttpClient<IBankIdService, BankIdService>()
            .ConfigurePrimaryHttpMessageHandler(() =>
            {
                var certPassword = configuration["BankId:CertificatePassword"] ?? "qwerty123";
                var handler = new HttpClientHandler();

                var certBase64 = configuration["BankId:CertificateBase64"];
                if (!string.IsNullOrWhiteSpace(certBase64))
                {
                    var certBytes = Convert.FromBase64String(certBase64);
                    handler.ClientCertificates.Add(new X509Certificate2(certBytes, certPassword));
                }
                else
                {
                    var certPath = configuration["BankId:CertificatePath"] ?? "certs/BankIdTest.pfx";
                    if (File.Exists(certPath))
                    {
                        var certBytes = File.ReadAllBytes(certPath);
                        handler.ClientCertificates.Add(new X509Certificate2(certBytes, certPassword));
                    }
                }

                handler.ServerCertificateCustomValidationCallback = (_, _, _, _) => true;
                return handler;
            });
        services.AddScoped<IJwtTokenService, JwtTokenService>();
        services.AddScoped<IEmailService, EmailService>();
        services.AddSingleton<ICardImageService, SkiaSharpCardImageService>();
        services.AddScoped<IWhatsAppService, TwilioWhatsAppService>();
        services.AddScoped<ISmsService, TwilioSmsService>();
        services.AddSingleton<IFcmService, FcmService>();   // Singleton: FirebaseApp init once
        services.AddSingleton<INotificationChannelSettings, NotificationChannelSettings>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<IDocumentService, DocumentService>();
        services.AddScoped<IDocumentPdfService, DocumentPdfService>();
        services.AddHttpClient("webhook");
        services.AddScoped<IWebhookService, WebhookService>();

        // Payment providers
        // Payment:Swish:Mock=true  → MockSwishPaymentService (dev, no certificate needed)
        // Payment:Swish:Mock=false → SwishPaymentService (real MSS with P12 certificate)
        var swishMock = configuration["Payment:Swish:Mock"] == "true";
        if (swishMock)
        {
            services.AddScoped<IPaymentService, MockSwishPaymentService>();
        }
        else
        {
            services.AddHttpClient<IPaymentService, SwishPaymentService>("Swish")
                .ConfigurePrimaryHttpMessageHandler(() =>
                {
                    var certPath = configuration["Payment:Swish:CertificatePath"];
                    var certPassword = configuration["Payment:Swish:CertificatePassword"] ?? "swish";
                    var handler = new HttpClientHandler();
                    if (!string.IsNullOrEmpty(certPath) && File.Exists(certPath))
                    {
                        var certBytes = File.ReadAllBytes(certPath);
                        handler.ClientCertificates.Add(new X509Certificate2(certBytes, certPassword));
                    }
                    handler.ServerCertificateCustomValidationCallback = (_, _, _, _) => true;
                    return handler;
                });
            services.AddScoped<IPaymentService, SwishPaymentService>();
        }
        services.AddHttpClient<IPaymentService, PayPalPaymentService>("PayPal");
        services.AddHttpClient<IPaymentService, KlarnaPaymentService>("Klarna");
        services.AddScoped<IPaymentService, PayPalPaymentService>();
        services.AddScoped<IPaymentService, KlarnaPaymentService>();
        services.AddScoped<IPaymentServiceFactory, PaymentServiceFactory>();

        // Background jobs
        services.AddHostedService<DelegationExpiryJob>();
        services.AddHostedService<DelegationExpiryWarningJob>();
        services.AddHostedService<LowCreditWarningJob>();

        return services;
    }
}

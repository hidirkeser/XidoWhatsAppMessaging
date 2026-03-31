using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Subscriptions.DTOs;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Subscriptions.Commands;

public record PurchaseSubscriptionCommand(
    Guid ProductId,
    string Provider,
    string? PayerPhone,
    string BaseUrl,
    string ReturnUrl
) : IRequest<object>;

public class PurchaseSubscriptionCommandHandler : IRequestHandler<PurchaseSubscriptionCommand, object>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly IPaymentServiceFactory _paymentFactory;
    private readonly INotificationService _notificationService;

    public PurchaseSubscriptionCommandHandler(
        IApplicationDbContext context, ICurrentUserService currentUser,
        IPaymentServiceFactory paymentFactory, INotificationService notificationService)
    {
        _context = context;
        _currentUser = currentUser;
        _paymentFactory = paymentFactory;
        _notificationService = notificationService;
    }

    public async Task<object> Handle(PurchaseSubscriptionCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == request.ProductId && p.IsActive, ct)
            ?? throw new NotFoundException("Product", request.ProductId);

        if (product.PriceSEK == 0)
        {
            // Free plan — activate directly
            await ActivateSubscription(userId, product, ct);
            return new { status = "activated", message = "Free subscription activated" };
        }

        // Create payment transaction
        if (!Enum.TryParse<PaymentProvider>(request.Provider, true, out var provider))
            throw new DomainException($"Invalid payment provider: {request.Provider}", "INVALID_PROVIDER");

        var tx = new PaymentTransaction
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            CreditPackageId = product.Id, // Reusing CreditPackageId field for product reference
            Provider = provider,
            AmountSEK = product.PriceSEK,
            CreditAmount = 0,
            Status = PaymentStatus.Pending
        };

        _context.PaymentTransactions.Add(tx);
        await _context.SaveChangesAsync(ct);

        var paymentService = _paymentFactory.GetService(provider);
        var callbackUrl = $"{request.BaseUrl}/api/credits/callback";
        var paymentRequest = new PaymentRequest(
            tx.Id, product.PriceSEK, "SEK",
            $"Minion {product.Name} - {product.Type}",
            callbackUrl, request.ReturnUrl, request.PayerPhone);
        var paymentResult = await paymentService.InitiatePaymentAsync(paymentRequest, ct);

        tx.ExternalPaymentId = paymentResult.ExternalPaymentId;
        tx.ExternalOrderRef = paymentResult.ExternalPaymentId;
        await _context.SaveChangesAsync(ct);

        return new
        {
            transactionId = tx.Id,
            productId = product.Id,
            paymentUrl = paymentResult.PaymentUrl,
            qrData = paymentResult.QrData,
            instructionId = paymentResult.ExternalPaymentId,
            provider = provider.ToString()
        };
    }

    private async Task ActivateSubscription(Guid userId, Product product, CancellationToken ct)
    {
        // Deactivate any existing active subscription
        var existing = await _context.UserSubscriptions
            .Where(s => s.UserId == userId && s.Status == SubscriptionStatus.Active)
            .ToListAsync(ct);

        foreach (var sub in existing)
        {
            sub.Status = SubscriptionStatus.Cancelled;
        }

        var subscription = new UserSubscription
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            ProductId = product.Id,
            StartDate = DateTime.UtcNow,
            EndDate = DateTime.UtcNow.AddMonths(1),
            RemainingQuota = product.MonthlyQuota,
            Status = SubscriptionStatus.Active,
            AutoRenew = product.PriceSEK == 0
        };

        _context.UserSubscriptions.Add(subscription);
        await _context.SaveChangesAsync(ct);

        await _notificationService.SendAsync(userId,
            "Abonnemang aktiverat",
            $"Din {product.Name}-plan är nu aktiv med {product.MonthlyQuota} operationer/månad.",
            NotificationType.SubscriptionPurchased, subscription.Id, ct);
    }
}

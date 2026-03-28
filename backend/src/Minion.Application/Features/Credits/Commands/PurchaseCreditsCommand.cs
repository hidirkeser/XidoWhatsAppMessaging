using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Credits.DTOs;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Credits.Commands;

public record PurchaseCreditsCommand(
    Guid CreditPackageId, string Provider, string? PayerPhone,
    string CallbackBaseUrl, string ReturnUrl) : IRequest<PurchaseCreditsResponse>;

public class PurchaseCreditsCommandHandler : IRequestHandler<PurchaseCreditsCommand, PurchaseCreditsResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly IPaymentServiceFactory _paymentFactory;
    private readonly IAuditLogService _audit;

    public PurchaseCreditsCommandHandler(
        IApplicationDbContext context, ICurrentUserService currentUser,
        IPaymentServiceFactory paymentFactory, IAuditLogService audit)
    {
        _context = context;
        _currentUser = currentUser;
        _paymentFactory = paymentFactory;
        _audit = audit;
    }

    public async Task<PurchaseCreditsResponse> Handle(PurchaseCreditsCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var package = await _context.CreditPackages.FirstOrDefaultAsync(
            p => p.Id == request.CreditPackageId && p.IsActive, ct)
            ?? throw new NotFoundException("CreditPackage", request.CreditPackageId);

        var provider = Enum.Parse<PaymentProvider>(request.Provider, ignoreCase: true);

        // Create payment transaction record
        var transaction = new PaymentTransaction
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            CreditPackageId = package.Id,
            Provider = provider,
            Status = PaymentStatus.Pending,
            AmountSEK = package.PriceSEK,
            CreditAmount = package.CreditAmount
        };
        _context.PaymentTransactions.Add(transaction);
        await _context.SaveChangesAsync(ct);

        // Initiate payment with provider
        var paymentService = _paymentFactory.GetService(provider);
        var callbackUrl = provider == PaymentProvider.Swish
            ? $"{request.CallbackBaseUrl}/api/credits/swish/callback"
            : $"{request.CallbackBaseUrl}/api/credits/callback";
        var result = await paymentService.InitiatePaymentAsync(new PaymentRequest(
            transaction.Id,
            package.PriceSEK,
            "SEK",
            $"Minion - {package.CreditAmount} kontor",
            callbackUrl,
            request.ReturnUrl,
            request.PayerPhone), ct);

        if (!result.Success)
        {
            transaction.Status = PaymentStatus.Failed;
            await _context.SaveChangesAsync(ct);
            throw new DomainException($"Payment initiation failed: {result.ErrorMessage}");
        }

        transaction.ExternalPaymentId = result.ExternalPaymentId;
        await _context.SaveChangesAsync(ct);

        return new PurchaseCreditsResponse(
            transaction.Id, request.Provider,
            result.PaymentUrl, result.QrData, result.ExternalPaymentId);
    }
}

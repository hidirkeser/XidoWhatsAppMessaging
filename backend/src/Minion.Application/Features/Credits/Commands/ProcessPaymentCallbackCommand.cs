using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Credits.Commands;

public record ProcessPaymentCallbackCommand(
    Guid TransactionId, string Provider, string CallbackData) : IRequest<bool>;

public class ProcessPaymentCallbackCommandHandler : IRequestHandler<ProcessPaymentCallbackCommand, bool>
{
    private readonly IApplicationDbContext _context;
    private readonly IPaymentServiceFactory _paymentFactory;
    private readonly ICreditService _creditService;
    private readonly IAuditLogService _audit;
    private readonly INotificationService _notificationService;

    public ProcessPaymentCallbackCommandHandler(
        IApplicationDbContext context, IPaymentServiceFactory paymentFactory,
        ICreditService creditService, IAuditLogService audit,
        INotificationService notificationService)
    {
        _context = context;
        _paymentFactory = paymentFactory;
        _creditService = creditService;
        _audit = audit;
        _notificationService = notificationService;
    }

    public async Task<bool> Handle(ProcessPaymentCallbackCommand request, CancellationToken ct)
    {
        var transaction = await _context.PaymentTransactions
            .FirstOrDefaultAsync(t => t.Id == request.TransactionId, ct)
            ?? throw new NotFoundException("PaymentTransaction", request.TransactionId);

        if (transaction.Status != PaymentStatus.Pending)
            return false;

        var provider = Enum.Parse<PaymentProvider>(request.Provider, ignoreCase: true);
        var paymentService = _paymentFactory.GetService(provider);

        var isValid = await paymentService.ValidateCallbackAsync(request.CallbackData, ct);
        if (!isValid)
        {
            transaction.Status = PaymentStatus.Failed;
            transaction.CallbackData = request.CallbackData;
            await _context.SaveChangesAsync(ct);
            return false;
        }

        // Add credits to user
        await _creditService.AddCreditsAsync(
            transaction.UserId, transaction.CreditAmount,
            transaction.CreditPackageId, transaction.UserId, ct);

        transaction.Status = PaymentStatus.Completed;
        transaction.CompletedAt = DateTime.UtcNow;
        transaction.CallbackData = request.CallbackData;
        await _context.SaveChangesAsync(ct);

        await _audit.LogAsync(AuditAction.CreditPurchase, transaction.UserId,
            details: new { transaction.CreditAmount, transaction.AmountSEK, Provider = provider.ToString() }, ct: ct);

        await _notificationService.SendAsync(
            transaction.UserId,
            "Kontor yüklendi!",
            $"{transaction.CreditAmount} kontor başarıyla hesabınıza eklendi.",
            NotificationType.CreditPurchaseSuccess,
            transaction.Id, ct);

        return true;
    }
}

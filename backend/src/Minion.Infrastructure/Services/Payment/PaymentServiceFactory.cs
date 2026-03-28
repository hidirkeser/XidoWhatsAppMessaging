using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services.Payment;

public class PaymentServiceFactory : IPaymentServiceFactory
{
    private readonly IEnumerable<IPaymentService> _services;

    public PaymentServiceFactory(IEnumerable<IPaymentService> services)
    {
        _services = services;
    }

    public IPaymentService GetService(PaymentProvider provider)
    {
        return _services.FirstOrDefault(s => s.Provider == provider)
            ?? throw new InvalidOperationException($"Payment provider '{provider}' is not configured.");
    }
}

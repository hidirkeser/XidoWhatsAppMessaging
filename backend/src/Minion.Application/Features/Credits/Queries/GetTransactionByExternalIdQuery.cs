using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Credits.Queries;

public record TransactionStatusDto(Guid TransactionId, string Status);

public record GetTransactionByExternalIdQuery(string ExternalId) : IRequest<TransactionStatusDto?>;

public class GetTransactionByExternalIdQueryHandler
    : IRequestHandler<GetTransactionByExternalIdQuery, TransactionStatusDto?>
{
    private readonly IApplicationDbContext _context;

    public GetTransactionByExternalIdQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<TransactionStatusDto?> Handle(
        GetTransactionByExternalIdQuery request, CancellationToken ct)
    {
        var tx = await _context.PaymentTransactions
            .FirstOrDefaultAsync(t => t.ExternalPaymentId == request.ExternalId, ct);

        if (tx == null) return null;
        return new TransactionStatusDto(tx.Id, tx.Status.ToString());
    }
}

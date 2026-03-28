using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Common.Models;
using Minion.Application.Features.Credits.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Credits.Queries;

public record GetCreditHistoryQuery(int Page = 1, int PageSize = 20) : IRequest<PaginatedList<CreditTransactionDto>>;

public class GetCreditHistoryQueryHandler : IRequestHandler<GetCreditHistoryQuery, PaginatedList<CreditTransactionDto>>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public GetCreditHistoryQueryHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<PaginatedList<CreditTransactionDto>> Handle(GetCreditHistoryQuery request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var query = _context.CreditTransactions
            .Where(t => t.UserId == userId)
            .OrderByDescending(t => t.CreatedAt)
            .Select(t => new CreditTransactionDto(
                t.Id, t.TransactionType.ToString(), t.Amount, t.BalanceAfter,
                t.Description, t.CreatedAt));

        return await PaginatedList<CreditTransactionDto>.CreateAsync(query, request.Page, request.PageSize, ct);
    }
}

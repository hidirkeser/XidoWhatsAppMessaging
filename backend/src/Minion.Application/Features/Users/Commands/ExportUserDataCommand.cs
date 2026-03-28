using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Users.Commands;

public record ExportUserDataCommand : IRequest<object>;

public class ExportUserDataCommandHandler : IRequestHandler<ExportUserDataCommand, object>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public ExportUserDataCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<object> Handle(ExportUserDataCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId, ct)
            ?? throw new NotFoundException("User", userId);

        var delegationsGranted = await _context.Delegations
            .Where(d => d.GrantorUserId == userId)
            .Select(d => new { d.Id, d.Status, d.ValidFrom, d.ValidTo, d.CreatedAt })
            .ToListAsync(ct);

        var delegationsReceived = await _context.Delegations
            .Where(d => d.DelegateUserId == userId)
            .Select(d => new { d.Id, d.Status, d.ValidFrom, d.ValidTo, d.CreatedAt })
            .ToListAsync(ct);

        var creditHistory = await _context.CreditTransactions
            .Where(t => t.UserId == userId)
            .Select(t => new { t.TransactionType, t.Amount, t.BalanceAfter, t.Description, t.CreatedAt })
            .ToListAsync(ct);

        return new
        {
            user = new { user.PersonalNumber, user.FirstName, user.LastName, user.Email, user.Phone, user.CreatedAt },
            delegationsGranted,
            delegationsReceived,
            creditHistory
        };
    }
}

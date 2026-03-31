using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Subscriptions.DTOs;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Subscriptions.Queries;

public record GetCurrentSubscriptionQuery : IRequest<SubscriptionDto?>;

public class GetCurrentSubscriptionQueryHandler : IRequestHandler<GetCurrentSubscriptionQuery, SubscriptionDto?>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public GetCurrentSubscriptionQueryHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<SubscriptionDto?> Handle(GetCurrentSubscriptionQuery request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var sub = await _context.UserSubscriptions
            .Include(s => s.Product)
            .Where(s => s.UserId == userId && s.Status == SubscriptionStatus.Active)
            .OrderByDescending(s => s.EndDate)
            .FirstOrDefaultAsync(ct);

        if (sub == null) return null;

        return new SubscriptionDto(sub.Id, sub.ProductId, sub.Product.Name, sub.Product.Type.ToString(),
            sub.StartDate, sub.EndDate, sub.RemainingQuota, sub.Product.MonthlyQuota,
            sub.Status.ToString(), sub.AutoRenew);
    }
}

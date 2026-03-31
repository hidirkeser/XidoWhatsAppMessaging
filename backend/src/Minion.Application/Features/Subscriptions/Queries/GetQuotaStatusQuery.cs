using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Subscriptions.DTOs;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Subscriptions.Queries;

public record GetQuotaStatusQuery : IRequest<QuotaStatusDto>;

public class GetQuotaStatusQueryHandler : IRequestHandler<GetQuotaStatusQuery, QuotaStatusDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public GetQuotaStatusQueryHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<QuotaStatusDto> Handle(GetQuotaStatusQuery request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var sub = await _context.UserSubscriptions
            .Include(s => s.Product)
            .Where(s => s.UserId == userId && s.Status == SubscriptionStatus.Active)
            .OrderByDescending(s => s.EndDate)
            .FirstOrDefaultAsync(ct);

        if (sub == null)
            return new QuotaStatusDto(false, 0, 0, null, null);

        return new QuotaStatusDto(true, sub.RemainingQuota, sub.Product.MonthlyQuota,
            sub.EndDate, sub.Product.Name);
    }
}

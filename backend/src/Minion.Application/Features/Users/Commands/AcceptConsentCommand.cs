using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Users.Commands;

public record AcceptConsentCommand(bool MarketingConsent) : IRequest<Unit>;

public class AcceptConsentCommandHandler : IRequestHandler<AcceptConsentCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public AcceptConsentCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<Unit> Handle(AcceptConsentCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId, ct)
            ?? throw new NotFoundException("User", userId);

        user.GdprConsentAcceptedAt = DateTime.UtcNow;
        user.GdprConsentVersion = "1.0";
        user.MarketingConsentAccepted = request.MarketingConsent;

        await _context.SaveChangesAsync(ct);
        return Unit.Value;
    }
}

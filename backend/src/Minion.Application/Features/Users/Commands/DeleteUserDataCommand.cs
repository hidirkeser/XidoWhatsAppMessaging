using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Users.Commands;

public record DeleteUserDataCommand : IRequest<Unit>;

public class DeleteUserDataCommandHandler : IRequestHandler<DeleteUserDataCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public DeleteUserDataCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<Unit> Handle(DeleteUserDataCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId, ct)
            ?? throw new NotFoundException("User", userId);

        // Anonymize personal data (GDPR right to erasure)
        user.PersonalNumber = $"DELETED-{user.Id.ToString()[..8]}";
        user.FirstName = "Deleted";
        user.LastName = "User";
        user.Email = null;
        user.Phone = null;
        user.IsActive = false;

        // Remove device tokens
        var tokens = await _context.DeviceTokens.Where(d => d.UserId == userId).ToListAsync(ct);
        foreach (var token in tokens) _context.DeviceTokens.Remove(token);

        await _context.SaveChangesAsync(ct);
        return Unit.Value;
    }
}

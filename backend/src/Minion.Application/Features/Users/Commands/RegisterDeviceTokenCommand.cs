using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Users.Commands;

public record RegisterDeviceTokenCommand(string Token, string Platform) : IRequest<Unit>;

public class RegisterDeviceTokenCommandHandler : IRequestHandler<RegisterDeviceTokenCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public RegisterDeviceTokenCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<Unit> Handle(RegisterDeviceTokenCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var existing = await _context.DeviceTokens
            .FirstOrDefaultAsync(d => d.Token == request.Token, ct);

        if (existing != null)
        {
            existing.UserId = userId;
            existing.IsActive = true;
            existing.UpdatedAt = DateTime.UtcNow;
        }
        else
        {
            _context.DeviceTokens.Add(new DeviceToken
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Token = request.Token,
                Platform = Enum.Parse<DevicePlatform>(request.Platform, ignoreCase: true),
                IsActive = true
            });
        }

        await _context.SaveChangesAsync(ct);
        return Unit.Value;
    }
}

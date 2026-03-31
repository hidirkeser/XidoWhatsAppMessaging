using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Users.DTOs;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Users.Commands;

public record UpdateProfileCommand(string? Email, string? Phone) : IRequest<UserDto>;

public class UpdateProfileCommandHandler : IRequestHandler<UpdateProfileCommand, UserDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public UpdateProfileCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<UserDto> Handle(UpdateProfileCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId, ct)
            ?? throw new NotFoundException("User", userId);

        if (!string.IsNullOrEmpty(request.Email)) user.Email = request.Email;
        if (!string.IsNullOrEmpty(request.Phone)) user.Phone = request.Phone;

        await _context.SaveChangesAsync(ct);

        return new UserDto(
            user.Id, user.PersonalNumber, user.FirstName, user.LastName,
            user.Email, user.Phone, user.IsAdmin, user.IsActive,
            user.CreatedAt, user.LastLoginAt, user.GdprConsentAcceptedAt);
    }
}

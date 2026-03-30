using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Entities;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Users.Commands;

public record UpdateNotificationPreferencesCommand(
    bool InAppEnabled,
    bool PushEnabled,
    bool EmailEnabled,
    bool WhatsAppEnabled,
    bool SmsEnabled) : IRequest<NotificationPreferencesDto>;

public record NotificationPreferencesDto(
    bool InAppEnabled,
    bool PushEnabled,
    bool EmailEnabled,
    bool WhatsAppEnabled,
    bool SmsEnabled);

public class UpdateNotificationPreferencesCommandHandler
    : IRequestHandler<UpdateNotificationPreferencesCommand, NotificationPreferencesDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public UpdateNotificationPreferencesCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<NotificationPreferencesDto> Handle(
        UpdateNotificationPreferencesCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var pref = await _context.UserNotificationPreferences
            .FirstOrDefaultAsync(p => p.UserId == userId, ct);

        if (pref == null)
        {
            pref = new UserNotificationPreference { Id = Guid.NewGuid(), UserId = userId };
            _context.UserNotificationPreferences.Add(pref);
        }

        pref.InAppEnabled    = request.InAppEnabled;
        pref.PushEnabled     = request.PushEnabled;
        pref.EmailEnabled    = request.EmailEnabled;
        pref.WhatsAppEnabled = request.WhatsAppEnabled;
        pref.SmsEnabled      = request.SmsEnabled;
        pref.UpdatedAt       = DateTime.UtcNow;

        await _context.SaveChangesAsync(ct);

        return new NotificationPreferencesDto(
            pref.InAppEnabled,
            pref.PushEnabled,
            pref.EmailEnabled,
            pref.WhatsAppEnabled,
            pref.SmsEnabled);
    }
}

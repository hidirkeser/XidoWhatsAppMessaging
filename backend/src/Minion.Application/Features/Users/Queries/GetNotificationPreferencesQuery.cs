using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Users.Commands;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Users.Queries;

public record GetNotificationPreferencesQuery : IRequest<NotificationPreferencesDto>;

public class GetNotificationPreferencesQueryHandler
    : IRequestHandler<GetNotificationPreferencesQuery, NotificationPreferencesDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly INotificationChannelSettings _channelSettings;

    public GetNotificationPreferencesQueryHandler(
        IApplicationDbContext context,
        ICurrentUserService currentUser,
        INotificationChannelSettings channelSettings)
    {
        _context = context;
        _currentUser = currentUser;
        _channelSettings = channelSettings;
    }

    public async Task<NotificationPreferencesDto> Handle(
        GetNotificationPreferencesQuery request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var pref = await _context.UserNotificationPreferences
            .FirstOrDefaultAsync(p => p.UserId == userId, ct);

        // Return defaults if no preference row exists yet
        return pref == null
            ? new NotificationPreferencesDto(
                true, true, true, false, false,
                InAppAvailable:    _channelSettings.InAppAvailable,
                PushAvailable:     _channelSettings.PushAvailable,
                EmailAvailable:    _channelSettings.EmailAvailable,
                WhatsAppAvailable: _channelSettings.WhatsAppAvailable,
                SmsAvailable:      _channelSettings.SmsAvailable)
            : new NotificationPreferencesDto(
                pref.InAppEnabled,
                pref.PushEnabled,
                pref.EmailEnabled,
                pref.WhatsAppEnabled,
                pref.SmsEnabled,
                InAppAvailable:    _channelSettings.InAppAvailable,
                PushAvailable:     _channelSettings.PushAvailable,
                EmailAvailable:    _channelSettings.EmailAvailable,
                WhatsAppAvailable: _channelSettings.WhatsAppAvailable,
                SmsAvailable:      _channelSettings.SmsAvailable);
    }
}

using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Admin.Queries;

public record NotificationSettingsDto(WhatsAppCardFormat WhatsAppCardFormat);

public record GetNotificationSettingsQuery : IRequest<NotificationSettingsDto>;

internal class GetNotificationSettingsQueryHandler
    : IRequestHandler<GetNotificationSettingsQuery, NotificationSettingsDto>
{
    private readonly IApplicationDbContext _context;

    public GetNotificationSettingsQueryHandler(IApplicationDbContext context)
        => _context = context;

    public async Task<NotificationSettingsDto> Handle(
        GetNotificationSettingsQuery request, CancellationToken ct)
    {
        var setting = await _context.AppSettings
            .FirstOrDefaultAsync(s => s.Key == "WhatsApp:CardFormat", ct);

        var format = WhatsAppCardFormat.ImageCard;
        if (setting != null && int.TryParse(setting.Value, out var v))
            format = (WhatsAppCardFormat)v;

        return new NotificationSettingsDto(format);
    }
}

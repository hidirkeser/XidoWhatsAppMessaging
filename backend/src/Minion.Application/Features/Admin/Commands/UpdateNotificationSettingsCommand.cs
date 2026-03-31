using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Admin.Commands;

public record UpdateNotificationSettingsCommand(WhatsAppCardFormat WhatsAppCardFormat) : IRequest;

internal class UpdateNotificationSettingsCommandHandler
    : IRequestHandler<UpdateNotificationSettingsCommand>
{
    private readonly IApplicationDbContext _context;

    public UpdateNotificationSettingsCommandHandler(IApplicationDbContext context)
        => _context = context;

    public async Task Handle(UpdateNotificationSettingsCommand request, CancellationToken ct)
    {
        var setting = await _context.AppSettings
            .FirstOrDefaultAsync(s => s.Key == "WhatsApp:CardFormat", ct);

        if (setting == null)
        {
            _context.AppSettings.Add(new AppSetting
            {
                Key   = "WhatsApp:CardFormat",
                Value = ((int)request.WhatsAppCardFormat).ToString()
            });
        }
        else
        {
            setting.Value = ((int)request.WhatsAppCardFormat).ToString();
        }

        await _context.SaveChangesAsync(ct);
    }
}

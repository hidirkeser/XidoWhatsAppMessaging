using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Entities;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.CorporateApplications.Commands;

public record SendCorporateOtpCommand(string Phone) : IRequest;

public class SendCorporateOtpCommandHandler : IRequestHandler<SendCorporateOtpCommand>
{
    private readonly IApplicationDbContext _context;
    private readonly ISmsService _sms;

    public SendCorporateOtpCommandHandler(IApplicationDbContext context, ISmsService sms)
    {
        _context = context;
        _sms = sms;
    }

    public async Task Handle(SendCorporateOtpCommand request, CancellationToken ct)
    {
        // Invalidate any previous unused OTPs for this phone
        var existing = await _context.CorporateOtps
            .Where(o => o.Phone == request.Phone && !o.IsUsed)
            .ToListAsync(ct);
        foreach (var old in existing) old.IsUsed = true;

        var code = Random.Shared.Next(100000, 999999).ToString();
        _context.CorporateOtps.Add(new CorporateOtp
        {
            Id        = Guid.NewGuid(),
            Phone     = request.Phone,
            Code      = code,
            ExpiresAt = DateTime.UtcNow.AddMinutes(5),
        });

        await _context.SaveChangesAsync(ct);

        await _sms.SendAsync(request.Phone,
            $"Minion doğrulama kodunuz: {code}. 5 dakika geçerlidir.", ct);
    }
}

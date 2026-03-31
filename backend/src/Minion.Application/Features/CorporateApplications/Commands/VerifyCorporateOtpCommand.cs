using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.CorporateApplications.Commands;

public record VerifyCorporateOtpCommand(string Phone, string Code) : IRequest;

public class VerifyCorporateOtpCommandHandler : IRequestHandler<VerifyCorporateOtpCommand>
{
    private readonly IApplicationDbContext _context;

    public VerifyCorporateOtpCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task Handle(VerifyCorporateOtpCommand request, CancellationToken ct)
    {
        var otp = await _context.CorporateOtps
            .Where(o => o.Phone == request.Phone && o.Code == request.Code && !o.IsUsed)
            .OrderByDescending(o => o.CreatedAt)
            .FirstOrDefaultAsync(ct);

        if (otp == null)
            throw new DomainException("Geçersiz doğrulama kodu.", "INVALID_OTP");

        if (otp.ExpiresAt < DateTime.UtcNow)
            throw new DomainException("Doğrulama kodunun süresi dolmuş.", "OTP_EXPIRED");

        otp.IsUsed = true;
        await _context.SaveChangesAsync(ct);
    }
}

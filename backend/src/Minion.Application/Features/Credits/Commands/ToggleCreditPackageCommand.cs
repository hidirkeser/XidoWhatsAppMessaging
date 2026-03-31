using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Credits.Commands;

public record ToggleCreditPackageCommand(Guid Id) : IRequest;

public class ToggleCreditPackageCommandHandler : IRequestHandler<ToggleCreditPackageCommand>
{
    private readonly IApplicationDbContext _context;

    public ToggleCreditPackageCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task Handle(ToggleCreditPackageCommand request, CancellationToken ct)
    {
        var cp = await _context.CreditPackages.FirstOrDefaultAsync(c => c.Id == request.Id, ct)
            ?? throw new NotFoundException("CreditPackage", request.Id);

        cp.IsActive = !cp.IsActive;
        await _context.SaveChangesAsync(ct);
    }
}

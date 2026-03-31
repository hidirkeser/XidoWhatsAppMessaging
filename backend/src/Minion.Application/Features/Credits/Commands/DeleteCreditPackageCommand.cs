using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Credits.Commands;

public record DeleteCreditPackageCommand(Guid Id) : IRequest;

public class DeleteCreditPackageCommandHandler : IRequestHandler<DeleteCreditPackageCommand>
{
    private readonly IApplicationDbContext _context;

    public DeleteCreditPackageCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task Handle(DeleteCreditPackageCommand request, CancellationToken ct)
    {
        var cp = await _context.CreditPackages.FirstOrDefaultAsync(c => c.Id == request.Id, ct)
            ?? throw new NotFoundException("CreditPackage", request.Id);

        cp.IsActive = false;
        await _context.SaveChangesAsync(ct);
    }
}

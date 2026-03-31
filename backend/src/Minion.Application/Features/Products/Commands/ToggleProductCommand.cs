using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Products.Commands;

public record ToggleProductCommand(Guid Id) : IRequest;

public class ToggleProductCommandHandler : IRequestHandler<ToggleProductCommand>
{
    private readonly IApplicationDbContext _context;

    public ToggleProductCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task Handle(ToggleProductCommand request, CancellationToken ct)
    {
        var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == request.Id, ct)
            ?? throw new NotFoundException("Product", request.Id);

        product.IsActive = !product.IsActive;
        await _context.SaveChangesAsync(ct);
    }
}

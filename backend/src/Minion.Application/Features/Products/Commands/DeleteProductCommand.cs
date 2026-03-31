using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Products.Commands;

public record DeleteProductCommand(Guid Id) : IRequest;

public class DeleteProductCommandHandler : IRequestHandler<DeleteProductCommand>
{
    private readonly IApplicationDbContext _context;

    public DeleteProductCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task Handle(DeleteProductCommand request, CancellationToken ct)
    {
        var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == request.Id, ct)
            ?? throw new NotFoundException("Product", request.Id);

        product.IsActive = false;
        await _context.SaveChangesAsync(ct);
    }
}

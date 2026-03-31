using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.WebProducts.Commands;

public record DeleteWebProductCommand(Guid Id) : IRequest;

public class DeleteWebProductCommandHandler : IRequestHandler<DeleteWebProductCommand>
{
    private readonly IApplicationDbContext _context;

    public DeleteWebProductCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task Handle(DeleteWebProductCommand request, CancellationToken ct)
    {
        var wp = await _context.WebProducts.FirstOrDefaultAsync(w => w.Id == request.Id, ct)
            ?? throw new NotFoundException("WebProduct", request.Id);

        wp.IsActive = false;
        await _context.SaveChangesAsync(ct);
    }
}

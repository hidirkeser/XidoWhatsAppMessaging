using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.WebProducts.Commands;

public record ToggleWebProductCommand(Guid Id) : IRequest;

public class ToggleWebProductCommandHandler : IRequestHandler<ToggleWebProductCommand>
{
    private readonly IApplicationDbContext _context;

    public ToggleWebProductCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task Handle(ToggleWebProductCommand request, CancellationToken ct)
    {
        var wp = await _context.WebProducts.FirstOrDefaultAsync(w => w.Id == request.Id, ct)
            ?? throw new NotFoundException("WebProduct", request.Id);

        wp.IsActive = !wp.IsActive;
        await _context.SaveChangesAsync(ct);
    }
}

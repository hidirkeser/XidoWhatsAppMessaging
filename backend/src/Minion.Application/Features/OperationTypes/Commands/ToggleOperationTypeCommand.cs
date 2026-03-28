using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.OperationTypes.Commands;

public record ToggleOperationTypeCommand(Guid Id) : IRequest<Unit>;

public class ToggleOperationTypeCommandHandler : IRequestHandler<ToggleOperationTypeCommand, Unit>
{
    private readonly IApplicationDbContext _context;

    public ToggleOperationTypeCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<Unit> Handle(ToggleOperationTypeCommand request, CancellationToken ct)
    {
        var ot = await _context.OperationTypes.FirstOrDefaultAsync(o => o.Id == request.Id, ct)
            ?? throw new NotFoundException("OperationType", request.Id);

        ot.IsActive = !ot.IsActive;
        await _context.SaveChangesAsync(ct);
        return Unit.Value;
    }
}

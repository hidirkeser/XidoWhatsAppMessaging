using MediatR;
using Minion.Application.Features.Credits.DTOs;
using Minion.Domain.Entities;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Credits.Commands;

public record CreateCreditPackageCommand(
    string Name, string? NameSv, int CreditAmount, decimal PriceSEK,
    string? Description, string? DescriptionSv, string? Badge, string? BadgeSv, int SortOrder
) : IRequest<CreditPackageAdminDto>;

public class CreateCreditPackageCommandHandler : IRequestHandler<CreateCreditPackageCommand, CreditPackageAdminDto>
{
    private readonly IApplicationDbContext _context;

    public CreateCreditPackageCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<CreditPackageAdminDto> Handle(CreateCreditPackageCommand request, CancellationToken ct)
    {
        var cp = new CreditPackage
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            NameSv = request.NameSv,
            CreditAmount = request.CreditAmount,
            PriceSEK = request.PriceSEK,
            Description = request.Description,
            DescriptionSv = request.DescriptionSv,
            Badge = request.Badge,
            BadgeSv = request.BadgeSv,
            SortOrder = request.SortOrder
        };

        _context.CreditPackages.Add(cp);
        await _context.SaveChangesAsync(ct);

        return new CreditPackageAdminDto(cp.Id, cp.Name, cp.NameSv, cp.CreditAmount, cp.PriceSEK,
            cp.Description, cp.DescriptionSv, cp.Badge, cp.BadgeSv, cp.IsActive, cp.SortOrder);
    }
}

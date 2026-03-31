using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Credits.DTOs;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Credits.Commands;

public record UpdateCreditPackageCommand(
    Guid Id, string? Name, string? NameSv, int? CreditAmount, decimal? PriceSEK,
    string? Description, string? DescriptionSv, string? Badge, string? BadgeSv, int? SortOrder
) : IRequest<CreditPackageAdminDto>;

public class UpdateCreditPackageCommandHandler : IRequestHandler<UpdateCreditPackageCommand, CreditPackageAdminDto>
{
    private readonly IApplicationDbContext _context;

    public UpdateCreditPackageCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<CreditPackageAdminDto> Handle(UpdateCreditPackageCommand request, CancellationToken ct)
    {
        var cp = await _context.CreditPackages.FirstOrDefaultAsync(c => c.Id == request.Id, ct)
            ?? throw new NotFoundException("CreditPackage", request.Id);

        if (!string.IsNullOrEmpty(request.Name)) cp.Name = request.Name;
        if (!string.IsNullOrEmpty(request.NameSv)) cp.NameSv = request.NameSv;
        if (request.CreditAmount.HasValue) cp.CreditAmount = request.CreditAmount.Value;
        if (request.PriceSEK.HasValue) cp.PriceSEK = request.PriceSEK.Value;
        if (!string.IsNullOrEmpty(request.Description)) cp.Description = request.Description;
        if (!string.IsNullOrEmpty(request.DescriptionSv)) cp.DescriptionSv = request.DescriptionSv;
        if (!string.IsNullOrEmpty(request.Badge)) cp.Badge = request.Badge;
        if (!string.IsNullOrEmpty(request.BadgeSv)) cp.BadgeSv = request.BadgeSv;
        if (request.SortOrder.HasValue) cp.SortOrder = request.SortOrder.Value;

        await _context.SaveChangesAsync(ct);

        return new CreditPackageAdminDto(cp.Id, cp.Name, cp.NameSv, cp.CreditAmount, cp.PriceSEK,
            cp.Description, cp.DescriptionSv, cp.Badge, cp.BadgeSv, cp.IsActive, cp.SortOrder);
    }
}

using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Credits.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Credits.Queries;

public record GetAllCreditPackagesQuery : IRequest<List<CreditPackageAdminDto>>;

public class GetAllCreditPackagesQueryHandler : IRequestHandler<GetAllCreditPackagesQuery, List<CreditPackageAdminDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllCreditPackagesQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<List<CreditPackageAdminDto>> Handle(GetAllCreditPackagesQuery request, CancellationToken ct)
    {
        return await _context.CreditPackages
            .OrderBy(cp => cp.SortOrder)
            .Select(cp => new CreditPackageAdminDto(
                cp.Id, cp.Name, cp.NameSv, cp.CreditAmount, cp.PriceSEK,
                cp.Description, cp.DescriptionSv, cp.Badge, cp.BadgeSv,
                cp.IsActive, cp.SortOrder))
            .ToListAsync(ct);
    }
}

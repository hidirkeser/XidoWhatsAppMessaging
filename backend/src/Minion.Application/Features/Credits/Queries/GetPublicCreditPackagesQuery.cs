using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Products.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Credits.Queries;

public record GetPublicCreditPackagesQuery(string Locale = "en") : IRequest<List<PublicCreditPackageDto>>;

public class GetPublicCreditPackagesQueryHandler : IRequestHandler<GetPublicCreditPackagesQuery, List<PublicCreditPackageDto>>
{
    private readonly IApplicationDbContext _context;

    public GetPublicCreditPackagesQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<List<PublicCreditPackageDto>> Handle(GetPublicCreditPackagesQuery request, CancellationToken ct)
    {
        var isSv = request.Locale.Equals("sv", StringComparison.OrdinalIgnoreCase);

        var packages = await _context.CreditPackages
            .Where(cp => cp.IsActive)
            .OrderBy(cp => cp.SortOrder)
            .ToListAsync(ct);

        return packages.Select(cp =>
        {
            var name = isSv ? (cp.NameSv ?? cp.Name) : cp.Name;
            var desc = isSv ? (cp.DescriptionSv ?? cp.Description) : cp.Description;
            var badge = isSv ? (cp.BadgeSv ?? cp.Badge) : cp.Badge;

            return new PublicCreditPackageDto(cp.Id, name, cp.CreditAmount, cp.PriceSEK, desc, badge, cp.SortOrder);
        }).ToList();
    }
}

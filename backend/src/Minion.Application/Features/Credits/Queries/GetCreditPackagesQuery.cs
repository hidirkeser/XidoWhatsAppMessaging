using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Credits.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Credits.Queries;

public record GetCreditPackagesQuery : IRequest<List<CreditPackageDto>>;

public class GetCreditPackagesQueryHandler : IRequestHandler<GetCreditPackagesQuery, List<CreditPackageDto>>
{
    private readonly IApplicationDbContext _context;

    public GetCreditPackagesQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<List<CreditPackageDto>> Handle(GetCreditPackagesQuery request, CancellationToken ct)
    {
        return await _context.CreditPackages
            .Where(p => p.IsActive)
            .OrderBy(p => p.SortOrder)
            .Select(p => new CreditPackageDto(p.Id, p.Name, p.CreditAmount, p.PriceSEK,
                p.Description, p.IsActive, p.SortOrder))
            .ToListAsync(ct);
    }
}

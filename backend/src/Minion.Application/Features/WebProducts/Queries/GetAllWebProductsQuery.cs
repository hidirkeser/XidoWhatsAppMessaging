using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.WebProducts.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.WebProducts.Queries;

public record GetAllWebProductsQuery : IRequest<List<WebProductAdminDto>>;

public class GetAllWebProductsQueryHandler : IRequestHandler<GetAllWebProductsQuery, List<WebProductAdminDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllWebProductsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<List<WebProductAdminDto>> Handle(GetAllWebProductsQuery request, CancellationToken ct)
    {
        return await _context.WebProducts
            .OrderBy(wp => wp.SortOrder)
            .Select(wp => new WebProductAdminDto(
                wp.Id, wp.Slug, wp.Icon, wp.Color,
                wp.NameEn, wp.DescriptionEn, wp.FeaturesEn,
                wp.NameSv, wp.DescriptionSv, wp.FeaturesSv,
                wp.IsActive, wp.SortOrder))
            .ToListAsync(ct);
    }
}

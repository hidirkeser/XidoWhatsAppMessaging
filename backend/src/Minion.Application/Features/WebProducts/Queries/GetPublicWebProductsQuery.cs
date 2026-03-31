using System.Text.Json;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.WebProducts.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.WebProducts.Queries;

public record GetPublicWebProductsQuery(string Locale = "en") : IRequest<List<WebProductDto>>;

public class GetPublicWebProductsQueryHandler : IRequestHandler<GetPublicWebProductsQuery, List<WebProductDto>>
{
    private readonly IApplicationDbContext _context;

    public GetPublicWebProductsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<List<WebProductDto>> Handle(GetPublicWebProductsQuery request, CancellationToken ct)
    {
        var isSv = request.Locale.Equals("sv", StringComparison.OrdinalIgnoreCase);

        var products = await _context.WebProducts
            .Where(wp => wp.IsActive)
            .OrderBy(wp => wp.SortOrder)
            .ToListAsync(ct);

        return products.Select(wp =>
        {
            var name = isSv ? wp.NameSv : wp.NameEn;
            var desc = isSv ? wp.DescriptionSv : wp.DescriptionEn;
            var featuresJson = isSv ? wp.FeaturesSv : wp.FeaturesEn;
            var features = JsonSerializer.Deserialize<string[]>(featuresJson) ?? [];

            return new WebProductDto(wp.Id, wp.Slug, name, desc, features, wp.Icon, wp.Color, wp.SortOrder);
        }).ToList();
    }
}

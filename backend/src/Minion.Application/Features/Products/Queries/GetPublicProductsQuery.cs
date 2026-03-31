using System.Text.Json;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Products.DTOs;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Products.Queries;

public record GetPublicProductsQuery(string Locale = "en", string? Type = null) : IRequest<List<PublicProductDto>>;

public class GetPublicProductsQueryHandler : IRequestHandler<GetPublicProductsQuery, List<PublicProductDto>>
{
    private readonly IApplicationDbContext _context;

    public GetPublicProductsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<List<PublicProductDto>> Handle(GetPublicProductsQuery request, CancellationToken ct)
    {
        var isSv = request.Locale.Equals("sv", StringComparison.OrdinalIgnoreCase);
        var query = _context.Products.Where(p => p.IsActive).AsQueryable();

        if (!string.IsNullOrEmpty(request.Type) && Enum.TryParse<ProductType>(request.Type, true, out var type))
            query = query.Where(p => p.Type == type);

        var products = await query.OrderBy(p => p.SortOrder).ToListAsync(ct);

        return products.Select(p =>
        {
            var name = isSv ? (p.NameSv ?? p.Name) : p.Name;
            var desc = isSv ? (p.DescriptionSv ?? p.Description) : p.Description;
            var featuresJson = isSv ? (p.FeaturesSv ?? p.Features) : p.Features;
            var badge = isSv ? (p.BadgeSv ?? p.Badge) : p.Badge;
            var features = !string.IsNullOrEmpty(featuresJson)
                ? JsonSerializer.Deserialize<string[]>(featuresJson) ?? []
                : [];

            return new PublicProductDto(p.Id, name, desc, p.Type.ToString(),
                p.MonthlyQuota, p.PriceSEK, features, badge, p.SortOrder);
        }).ToList();
    }
}

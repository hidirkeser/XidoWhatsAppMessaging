using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Products.DTOs;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Products.Queries;

public record GetProductsQuery(string? Type = null) : IRequest<List<ProductDto>>;

public class GetProductsQueryHandler : IRequestHandler<GetProductsQuery, List<ProductDto>>
{
    private readonly IApplicationDbContext _context;

    public GetProductsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<List<ProductDto>> Handle(GetProductsQuery request, CancellationToken ct)
    {
        var query = _context.Products.Where(p => p.IsActive).AsQueryable();

        if (!string.IsNullOrEmpty(request.Type) && Enum.TryParse<ProductType>(request.Type, true, out var type))
            query = query.Where(p => p.Type == type);

        return await query
            .OrderBy(p => p.SortOrder)
            .Select(p => new ProductDto(p.Id, p.Name, p.Description, p.Type.ToString(),
                p.MonthlyQuota, p.PriceSEK, p.Features, p.IsActive, p.SortOrder))
            .ToListAsync(ct);
    }
}

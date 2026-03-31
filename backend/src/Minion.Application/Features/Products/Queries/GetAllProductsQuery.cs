using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Products.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Products.Queries;

public record GetAllProductsQuery : IRequest<List<ProductDto>>;

public class GetAllProductsQueryHandler : IRequestHandler<GetAllProductsQuery, List<ProductDto>>
{
    private readonly IApplicationDbContext _context;

    public GetAllProductsQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<List<ProductDto>> Handle(GetAllProductsQuery request, CancellationToken ct)
    {
        return await _context.Products
            .OrderBy(p => p.SortOrder)
            .Select(p => new ProductDto(p.Id, p.Name, p.Description, p.Type.ToString(),
                p.MonthlyQuota, p.PriceSEK, p.Features, p.IsActive, p.SortOrder))
            .ToListAsync(ct);
    }
}

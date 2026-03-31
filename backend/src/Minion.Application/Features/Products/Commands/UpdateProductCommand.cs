using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Products.DTOs;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Products.Commands;

public record UpdateProductCommand(
    Guid Id,
    string? Name,
    string? Description,
    string? Type,
    int? MonthlyQuota,
    decimal? PriceSEK,
    string? Features,
    int? SortOrder
) : IRequest<ProductDto>;

public class UpdateProductCommandHandler : IRequestHandler<UpdateProductCommand, ProductDto>
{
    private readonly IApplicationDbContext _context;

    public UpdateProductCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<ProductDto> Handle(UpdateProductCommand request, CancellationToken ct)
    {
        var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == request.Id, ct)
            ?? throw new NotFoundException("Product", request.Id);

        if (!string.IsNullOrEmpty(request.Name)) product.Name = request.Name;
        if (!string.IsNullOrEmpty(request.Description)) product.Description = request.Description;
        if (!string.IsNullOrEmpty(request.Type))
        {
            if (!Enum.TryParse<ProductType>(request.Type, true, out var type))
                throw new DomainException($"Invalid product type: {request.Type}", "INVALID_PRODUCT_TYPE");
            product.Type = type;
        }
        if (request.MonthlyQuota.HasValue) product.MonthlyQuota = request.MonthlyQuota.Value;
        if (request.PriceSEK.HasValue) product.PriceSEK = request.PriceSEK.Value;
        if (!string.IsNullOrEmpty(request.Features)) product.Features = request.Features;
        if (request.SortOrder.HasValue) product.SortOrder = request.SortOrder.Value;

        await _context.SaveChangesAsync(ct);

        return new ProductDto(product.Id, product.Name, product.Description, product.Type.ToString(),
            product.MonthlyQuota, product.PriceSEK, product.Features, product.IsActive, product.SortOrder);
    }
}

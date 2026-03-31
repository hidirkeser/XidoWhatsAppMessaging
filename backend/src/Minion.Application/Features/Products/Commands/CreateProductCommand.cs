using MediatR;
using Minion.Application.Features.Products.DTOs;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Products.Commands;

public record CreateProductCommand(
    string Name,
    string? Description,
    string Type,
    int MonthlyQuota,
    decimal PriceSEK,
    string? Features,
    int SortOrder
) : IRequest<ProductDto>;

public class CreateProductCommandHandler : IRequestHandler<CreateProductCommand, ProductDto>
{
    private readonly IApplicationDbContext _context;

    public CreateProductCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<ProductDto> Handle(CreateProductCommand request, CancellationToken ct)
    {
        if (!Enum.TryParse<ProductType>(request.Type, true, out var type))
            throw new DomainException($"Invalid product type: {request.Type}", "INVALID_PRODUCT_TYPE");

        var product = new Product
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            Description = request.Description,
            Type = type,
            MonthlyQuota = request.MonthlyQuota,
            PriceSEK = request.PriceSEK,
            Features = request.Features,
            SortOrder = request.SortOrder
        };

        _context.Products.Add(product);
        await _context.SaveChangesAsync(ct);

        return new ProductDto(product.Id, product.Name, product.Description, product.Type.ToString(),
            product.MonthlyQuota, product.PriceSEK, product.Features, product.IsActive, product.SortOrder);
    }
}

using MediatR;
using Minion.Application.Features.WebProducts.DTOs;
using Minion.Domain.Entities;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.WebProducts.Commands;

public record CreateWebProductCommand(
    string Slug,
    string Icon,
    string Color,
    string NameEn,
    string DescriptionEn,
    string FeaturesEn,
    string NameSv,
    string DescriptionSv,
    string FeaturesSv,
    int SortOrder
) : IRequest<WebProductAdminDto>;

public class CreateWebProductCommandHandler : IRequestHandler<CreateWebProductCommand, WebProductAdminDto>
{
    private readonly IApplicationDbContext _context;

    public CreateWebProductCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<WebProductAdminDto> Handle(CreateWebProductCommand request, CancellationToken ct)
    {
        var wp = new WebProduct
        {
            Id = Guid.NewGuid(),
            Slug = request.Slug,
            Icon = request.Icon,
            Color = request.Color,
            NameEn = request.NameEn,
            DescriptionEn = request.DescriptionEn,
            FeaturesEn = request.FeaturesEn,
            NameSv = request.NameSv,
            DescriptionSv = request.DescriptionSv,
            FeaturesSv = request.FeaturesSv,
            SortOrder = request.SortOrder
        };

        _context.WebProducts.Add(wp);
        await _context.SaveChangesAsync(ct);

        return new WebProductAdminDto(wp.Id, wp.Slug, wp.Icon, wp.Color,
            wp.NameEn, wp.DescriptionEn, wp.FeaturesEn,
            wp.NameSv, wp.DescriptionSv, wp.FeaturesSv,
            wp.IsActive, wp.SortOrder);
    }
}

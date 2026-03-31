using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.WebProducts.DTOs;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.WebProducts.Commands;

public record UpdateWebProductCommand(
    Guid Id,
    string? Slug,
    string? Icon,
    string? Color,
    string? NameEn,
    string? DescriptionEn,
    string? FeaturesEn,
    string? NameSv,
    string? DescriptionSv,
    string? FeaturesSv,
    int? SortOrder
) : IRequest<WebProductAdminDto>;

public class UpdateWebProductCommandHandler : IRequestHandler<UpdateWebProductCommand, WebProductAdminDto>
{
    private readonly IApplicationDbContext _context;

    public UpdateWebProductCommandHandler(IApplicationDbContext context) => _context = context;

    public async Task<WebProductAdminDto> Handle(UpdateWebProductCommand request, CancellationToken ct)
    {
        var wp = await _context.WebProducts.FirstOrDefaultAsync(w => w.Id == request.Id, ct)
            ?? throw new NotFoundException("WebProduct", request.Id);

        if (!string.IsNullOrEmpty(request.Slug)) wp.Slug = request.Slug;
        if (!string.IsNullOrEmpty(request.Icon)) wp.Icon = request.Icon;
        if (!string.IsNullOrEmpty(request.Color)) wp.Color = request.Color;
        if (!string.IsNullOrEmpty(request.NameEn)) wp.NameEn = request.NameEn;
        if (!string.IsNullOrEmpty(request.DescriptionEn)) wp.DescriptionEn = request.DescriptionEn;
        if (!string.IsNullOrEmpty(request.FeaturesEn)) wp.FeaturesEn = request.FeaturesEn;
        if (!string.IsNullOrEmpty(request.NameSv)) wp.NameSv = request.NameSv;
        if (!string.IsNullOrEmpty(request.DescriptionSv)) wp.DescriptionSv = request.DescriptionSv;
        if (!string.IsNullOrEmpty(request.FeaturesSv)) wp.FeaturesSv = request.FeaturesSv;
        if (request.SortOrder.HasValue) wp.SortOrder = request.SortOrder.Value;

        await _context.SaveChangesAsync(ct);

        return new WebProductAdminDto(wp.Id, wp.Slug, wp.Icon, wp.Color,
            wp.NameEn, wp.DescriptionEn, wp.FeaturesEn,
            wp.NameSv, wp.DescriptionSv, wp.FeaturesSv,
            wp.IsActive, wp.SortOrder);
    }
}

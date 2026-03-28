using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Credits.DTOs;
using Minion.Domain.Entities;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/admin/credit-packages")]
[Authorize(Policy = "AdminOnly")]
public class CreditPackagesController : ControllerBase
{
    private readonly IApplicationDbContext _context;

    public CreditPackagesController(IApplicationDbContext context) => _context = context;

    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {
        var packages = await _context.CreditPackages
            .OrderBy(p => p.SortOrder)
            .Select(p => new CreditPackageDto(p.Id, p.Name, p.CreditAmount, p.PriceSEK,
                p.Description, p.IsActive, p.SortOrder))
            .ToListAsync(ct);
        return Ok(packages);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateCreditPackageRequest request, CancellationToken ct)
    {
        var package = new CreditPackage
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            CreditAmount = request.CreditAmount,
            PriceSEK = request.PriceSEK,
            Description = request.Description,
            SortOrder = request.SortOrder
        };
        _context.CreditPackages.Add(package);
        await _context.SaveChangesAsync(ct);
        return Created("", new CreditPackageDto(package.Id, package.Name, package.CreditAmount,
            package.PriceSEK, package.Description, package.IsActive, package.SortOrder));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateCreditPackageRequest request, CancellationToken ct)
    {
        var package = await _context.CreditPackages.FirstOrDefaultAsync(p => p.Id == id, ct)
            ?? throw new NotFoundException("CreditPackage", id);

        if (request.Name != null) package.Name = request.Name;
        if (request.CreditAmount.HasValue) package.CreditAmount = request.CreditAmount.Value;
        if (request.PriceSEK.HasValue) package.PriceSEK = request.PriceSEK.Value;
        if (request.Description != null) package.Description = request.Description;
        if (request.SortOrder.HasValue) package.SortOrder = request.SortOrder.Value;

        await _context.SaveChangesAsync(ct);
        return Ok(new CreditPackageDto(package.Id, package.Name, package.CreditAmount,
            package.PriceSEK, package.Description, package.IsActive, package.SortOrder));
    }

    [HttpPatch("{id:guid}/toggle")]
    public async Task<IActionResult> Toggle(Guid id, CancellationToken ct)
    {
        var package = await _context.CreditPackages.FirstOrDefaultAsync(p => p.Id == id, ct)
            ?? throw new NotFoundException("CreditPackage", id);

        package.IsActive = !package.IsActive;
        await _context.SaveChangesAsync(ct);
        return Ok();
    }
}

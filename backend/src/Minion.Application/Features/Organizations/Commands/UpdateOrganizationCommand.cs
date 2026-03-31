using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Organizations.DTOs;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Organizations.Commands;

public record UpdateOrganizationCommand(
    Guid Id, string? Name, string? Address, string? City,
    string? PostalCode, string? ContactEmail, string? ContactPhone,
    string? CallbackUrl) : IRequest<OrganizationDto>;

public class UpdateOrganizationCommandHandler : IRequestHandler<UpdateOrganizationCommand, OrganizationDto>
{
    private readonly IApplicationDbContext _context;
    private readonly IAuditLogService _audit;

    public UpdateOrganizationCommandHandler(IApplicationDbContext context, IAuditLogService audit)
    {
        _context = context;
        _audit = audit;
    }

    public async Task<OrganizationDto> Handle(UpdateOrganizationCommand request, CancellationToken ct)
    {
        var org = await _context.Organizations.FirstOrDefaultAsync(o => o.Id == request.Id, ct)
            ?? throw new NotFoundException("Organization", request.Id);

        if (!string.IsNullOrEmpty(request.Name)) org.Name = request.Name;
        if (!string.IsNullOrEmpty(request.Address)) org.Address = request.Address;
        if (!string.IsNullOrEmpty(request.City)) org.City = request.City;
        if (!string.IsNullOrEmpty(request.PostalCode)) org.PostalCode = request.PostalCode;
        if (!string.IsNullOrEmpty(request.ContactEmail)) org.ContactEmail = request.ContactEmail;
        if (!string.IsNullOrEmpty(request.ContactPhone)) org.ContactPhone = request.ContactPhone;
        if (!string.IsNullOrEmpty(request.CallbackUrl)) org.CallbackUrl = request.CallbackUrl;

        await _context.SaveChangesAsync(ct);
        await _audit.LogAsync(AuditAction.OrganizationUpdate, organizationId: org.Id, ct: ct);

        return new OrganizationDto(org.Id, org.Name, org.OrgNumber, org.Address,
            org.City, org.PostalCode, org.ContactEmail, org.ContactPhone,
            org.IsActive, org.CallbackUrl, org.CreatedAt);
    }
}

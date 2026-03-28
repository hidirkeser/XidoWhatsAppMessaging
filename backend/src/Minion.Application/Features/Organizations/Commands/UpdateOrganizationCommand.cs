using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Organizations.DTOs;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Organizations.Commands;

public record UpdateOrganizationCommand(
    Guid Id, string? Name, string? Address, string? City,
    string? PostalCode, string? ContactEmail, string? ContactPhone) : IRequest<OrganizationDto>;

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

        if (request.Name != null) org.Name = request.Name;
        if (request.Address != null) org.Address = request.Address;
        if (request.City != null) org.City = request.City;
        if (request.PostalCode != null) org.PostalCode = request.PostalCode;
        if (request.ContactEmail != null) org.ContactEmail = request.ContactEmail;
        if (request.ContactPhone != null) org.ContactPhone = request.ContactPhone;

        await _context.SaveChangesAsync(ct);
        await _audit.LogAsync(AuditAction.OrganizationUpdate, organizationId: org.Id, ct: ct);

        return new OrganizationDto(org.Id, org.Name, org.OrgNumber, org.Address,
            org.City, org.PostalCode, org.ContactEmail, org.ContactPhone,
            org.IsActive, org.CreatedAt);
    }
}

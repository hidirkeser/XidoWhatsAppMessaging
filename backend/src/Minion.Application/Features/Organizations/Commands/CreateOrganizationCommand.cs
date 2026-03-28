using MediatR;
using Minion.Application.Features.Organizations.DTOs;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Organizations.Commands;

public record CreateOrganizationCommand(
    string Name, string OrgNumber, string? Address, string? City,
    string? PostalCode, string? ContactEmail, string? ContactPhone) : IRequest<OrganizationDto>;

public class CreateOrganizationCommandHandler : IRequestHandler<CreateOrganizationCommand, OrganizationDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;
    private readonly IAuditLogService _audit;

    public CreateOrganizationCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser, IAuditLogService audit)
    {
        _context = context;
        _currentUser = currentUser;
        _audit = audit;
    }

    public async Task<OrganizationDto> Handle(CreateOrganizationCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var org = new Organization
        {
            Id = Guid.NewGuid(),
            Name = request.Name,
            OrgNumber = request.OrgNumber,
            Address = request.Address,
            City = request.City,
            PostalCode = request.PostalCode,
            ContactEmail = request.ContactEmail,
            ContactPhone = request.ContactPhone,
            CreatedByUserId = userId
        };

        _context.Organizations.Add(org);
        await _context.SaveChangesAsync(ct);

        await _audit.LogAsync(AuditAction.OrganizationCreate, organizationId: org.Id, ct: ct);

        return new OrganizationDto(org.Id, org.Name, org.OrgNumber, org.Address,
            org.City, org.PostalCode, org.ContactEmail, org.ContactPhone,
            org.IsActive, org.CreatedAt);
    }
}

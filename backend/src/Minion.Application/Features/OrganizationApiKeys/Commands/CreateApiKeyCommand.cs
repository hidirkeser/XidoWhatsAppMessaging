using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.OrganizationApiKeys.DTOs;
using Minion.Domain.Entities;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.OrganizationApiKeys.Commands;

public record CreateApiKeyCommand(Guid OrganizationId, string Name) : IRequest<ApiKeyCreatedDto>;

public class CreateApiKeyCommandHandler : IRequestHandler<CreateApiKeyCommand, ApiKeyCreatedDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public CreateApiKeyCommandHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<ApiKeyCreatedDto> Handle(CreateApiKeyCommand request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var org = await _context.Organizations
            .FirstOrDefaultAsync(o => o.Id == request.OrganizationId && !o.IsDeleted, ct)
            ?? throw new NotFoundException("Organization", request.OrganizationId);

        if (!org.IsActive)
            throw new DomainException("Organization is not active.", "ORG_NOT_ACTIVE");

        // Ensure the requesting user belongs to this org
        var isMember = await _context.UserOrganizations
            .AnyAsync(uo => uo.OrganizationId == request.OrganizationId
                         && uo.UserId == userId && uo.IsActive, ct);
        if (!isMember)
            throw new DomainException("Access denied.", "NOT_ORG_MEMBER");

        var keyId     = Guid.NewGuid().ToString("N");
        var secret    = Convert.ToBase64String(System.Security.Cryptography.RandomNumberGenerator.GetBytes(32));
        var secretHash = BCrypt.Net.BCrypt.HashPassword(secret);

        var apiKey = new OrganizationApiKey
        {
            Id             = Guid.NewGuid(),
            OrganizationId = request.OrganizationId,
            Name           = request.Name,
            KeyId          = keyId,
            SecretHash     = secretHash,
            CreatedByUserId = userId,
        };

        _context.OrganizationApiKeys.Add(apiKey);
        await _context.SaveChangesAsync(ct);

        return new ApiKeyCreatedDto(apiKey.Id, keyId, secret, request.Name, apiKey.CreatedAt);
    }
}

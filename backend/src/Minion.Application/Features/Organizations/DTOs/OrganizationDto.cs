namespace Minion.Application.Features.Organizations.DTOs;

public record OrganizationDto(
    Guid Id,
    string Name,
    string OrgNumber,
    string? Address,
    string? City,
    string? PostalCode,
    string? ContactEmail,
    string? ContactPhone,
    bool IsActive,
    string? CallbackUrl,
    DateTime CreatedAt);

public record CreateOrganizationRequest(
    string Name,
    string OrgNumber,
    string? Address,
    string? City,
    string? PostalCode,
    string? ContactEmail,
    string? ContactPhone);

public record UpdateOrganizationRequest(
    string? Name,
    string? Address,
    string? City,
    string? PostalCode,
    string? ContactEmail,
    string? ContactPhone,
    string? CallbackUrl);

public record AssignUserToOrgRequest(Guid UserId, string Role = "Member");

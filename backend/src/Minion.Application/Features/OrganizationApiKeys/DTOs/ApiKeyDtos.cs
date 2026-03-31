namespace Minion.Application.Features.OrganizationApiKeys.DTOs;

public record ApiKeyDto(
    Guid Id,
    string KeyId,
    string Name,
    bool IsActive,
    DateTime? LastUsedAt,
    int RequestCount,
    DateTime CreatedAt
);

/// <summary>Returned only once upon key creation — includes the plain-text secret.</summary>
public record ApiKeyCreatedDto(
    Guid Id,
    string KeyId,
    string Secret,   // shown once, never stored in plain text
    string Name,
    DateTime CreatedAt
);

public record CreateApiKeyRequest(string Name);

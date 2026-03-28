using Minion.Domain.Entities;

namespace Minion.Domain.Interfaces;

public interface IJwtTokenService
{
    string GenerateAccessToken(User user);
    string GenerateRefreshToken();
    Guid? ValidateRefreshToken(string token);

    /// <summary>Generates a 7-day signed token embedding delegationId, delegateUserId and action ("accept"|"reject").</summary>
    string GenerateDelegationActionToken(Guid delegationId, Guid delegateUserId, string action);

    /// <summary>Validates the delegation action token and extracts its claims.</summary>
    (bool Valid, Guid DelegationId, Guid DelegateUserId, string Action) ValidateDelegationActionToken(string token);
}

namespace Minion.Domain.Interfaces;

public interface IWebhookService
{
    /// <summary>
    /// Fires and forgets a POST to the org's CallbackUrl when a delegation is accepted.
    /// </summary>
    Task SendDelegationAcceptedAsync(Guid organizationId, Guid delegationId, string verificationCode, CancellationToken ct = default);
}

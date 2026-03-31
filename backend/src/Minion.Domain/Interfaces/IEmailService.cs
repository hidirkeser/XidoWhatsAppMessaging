namespace Minion.Domain.Interfaces;

public interface IEmailService
{
    Task SendAsync(string toEmail, string subject, string body, CancellationToken ct = default);

    Task SendDelegationRequestAsync(
        string toEmail,
        string toName,
        string grantorName,
        string orgName,
        string operationNames,
        DateTime validFrom,
        DateTime validTo,
        string? notes,
        string acceptUrl,
        string rejectUrl,
        CancellationToken ct = default);
}

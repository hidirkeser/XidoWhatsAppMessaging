namespace Minion.Domain.Interfaces;

public interface ISmsService
{
    Task SendAsync(string toPhone, string message, CancellationToken ct = default);

    Task SendDelegationRequestAsync(
        string toPhone,
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

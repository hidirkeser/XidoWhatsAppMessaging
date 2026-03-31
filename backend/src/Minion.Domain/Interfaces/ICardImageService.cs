namespace Minion.Domain.Interfaces;

public interface ICardImageService
{
    /// <summary>
    /// Verilen parametrelerle bir PNG kart oluşturur ve byte dizisi döner.
    /// </summary>
    byte[] GenerateDelegationCard(
        string grantorName,
        string delegateName,
        string orgName,
        string operationNames,
        DateTime validFrom,
        DateTime validTo,
        string? notes);
}

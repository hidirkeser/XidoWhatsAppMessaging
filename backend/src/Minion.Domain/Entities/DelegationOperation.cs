namespace Minion.Domain.Entities;

public class DelegationOperation
{
    public Guid Id { get; set; }
    public Guid DelegationId { get; set; }
    public Guid OperationTypeId { get; set; }

    public Delegation Delegation { get; set; } = null!;
    public OperationType OperationType { get; set; } = null!;
}

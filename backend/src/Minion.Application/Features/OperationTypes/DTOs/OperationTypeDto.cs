namespace Minion.Application.Features.OperationTypes.DTOs;

public record OperationTypeDto(
    Guid Id, Guid OrganizationId, string Name, string? Description,
    string? Icon, int CreditCost, bool IsActive, int SortOrder);

public record CreateOperationTypeRequest(
    string Name, string? Description, string? Icon, int CreditCost = 1, int SortOrder = 0);

public record UpdateOperationTypeRequest(
    string? Name, string? Description, string? Icon, int? CreditCost, int? SortOrder);

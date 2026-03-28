namespace Minion.Application.Features.Admin.DTOs;

public record DashboardStatsDto(
    int TotalUsers,
    int TotalOrganizations,
    int ActiveDelegations,
    int PendingDelegations,
    int TotalDelegations,
    int TotalCreditsSold,
    decimal TotalRevenueSEK,
    List<DelegationsByStatusDto> DelegationsByStatus);

public record DelegationsByStatusDto(string Status, int Count);

public record AuditLogDto(
    Guid Id, DateTime Timestamp, string? ActorName, string Action,
    Guid? TargetUserId, string? OrganizationName,
    string? Details, string? IpAddress);

public record AuditLogFilterDto(
    string? Action = null,
    Guid? ActorUserId = null,
    Guid? OrganizationId = null,
    DateTime? DateFrom = null,
    DateTime? DateTo = null,
    int Page = 1,
    int PageSize = 50);

public record ManualCreditAdjustRequest(int Amount, string Description);

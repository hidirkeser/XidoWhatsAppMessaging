namespace Minion.Application.Features.Notifications.DTOs;

public record NotificationDto(
    Guid Id, string Title, string Body, string Type,
    Guid? ReferenceId, bool IsRead, DateTime CreatedAt, DateTime? ReadAt);

public record UnreadCountDto(int Count);

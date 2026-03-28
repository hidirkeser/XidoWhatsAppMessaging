using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Common.Models;
using Minion.Application.Features.Notifications.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Notifications.Queries;

public record GetNotificationsQuery(int Page = 1, int PageSize = 20) : IRequest<PaginatedList<NotificationDto>>;

public class GetNotificationsQueryHandler : IRequestHandler<GetNotificationsQuery, PaginatedList<NotificationDto>>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public GetNotificationsQueryHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<PaginatedList<NotificationDto>> Handle(GetNotificationsQuery request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var query = _context.Notifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .Select(n => new NotificationDto(
                n.Id, n.Title, n.Body, n.Type.ToString(),
                n.ReferenceId, n.IsRead, n.CreatedAt, n.ReadAt));

        return await PaginatedList<NotificationDto>.CreateAsync(query, request.Page, request.PageSize, ct);
    }
}

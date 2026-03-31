using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Notifications.Commands;
using Minion.Application.Features.Notifications.Queries;
using Minion.Domain.Interfaces;

namespace Minion.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public NotificationsController(IMediator mediator, IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _mediator = mediator;
        _context = context;
        _currentUser = currentUser;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] int page = 1, [FromQuery] int pageSize = 20, CancellationToken ct = default)
        => Ok(await _mediator.Send(new GetNotificationsQuery(page, pageSize), ct));

    [HttpGet("unread-count")]
    public async Task<IActionResult> GetUnreadCount(CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();
        var count = await _context.Notifications.CountAsync(n => n.UserId == userId && !n.IsRead, ct);
        return Ok(new { count });
    }

    [HttpPatch("{id:guid}/read")]
    public async Task<IActionResult> MarkRead(Guid id, CancellationToken ct)
    {
        await _mediator.Send(new MarkNotificationReadCommand(id), ct);
        return Ok();
    }

    [HttpPost("mark-all-read")]
    public async Task<IActionResult> MarkAllRead(CancellationToken ct)
    {
        await _mediator.Send(new MarkAllNotificationsReadCommand(), ct);
        return Ok();
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        await _mediator.Send(new DeleteNotificationCommand(id), ct);
        return NoContent();
    }

    [HttpDelete]
    public async Task<IActionResult> DeleteAll(CancellationToken ct)
    {
        await _mediator.Send(new DeleteAllNotificationsCommand(), ct);
        return NoContent();
    }
}

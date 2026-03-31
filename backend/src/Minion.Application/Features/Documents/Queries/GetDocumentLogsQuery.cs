using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Documents.DTOs;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Documents.Queries;

public record GetDocumentLogsQuery(Guid DelegationId) : IRequest<List<DocumentLogDto>>;

public class GetDocumentLogsQueryHandler : IRequestHandler<GetDocumentLogsQuery, List<DocumentLogDto>>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public GetDocumentLogsQueryHandler(IApplicationDbContext context, ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;
    }

    public async Task<List<DocumentLogDto>> Handle(GetDocumentLogsQuery request, CancellationToken ct)
    {
        _ = _currentUser.UserId ?? throw new UnauthorizedAccessException();

        var doc = await _context.DelegationDocuments
            .FirstOrDefaultAsync(d => d.DelegationId == request.DelegationId, ct)
            ?? throw new NotFoundException("DelegationDocument", request.DelegationId);

        var logs = await _context.DelegationDocumentLogs
            .Where(l => l.DelegationDocumentId == doc.Id)
            .OrderByDescending(l => l.Timestamp)
            .Select(l => new DocumentLogDto(
                l.Id, l.ActorUserId, l.ActorName,
                l.Action.ToString(), l.Details,
                l.IpAddress, l.Timestamp))
            .ToListAsync(ct);

        return logs;
    }
}

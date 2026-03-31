using MediatR;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.CorporateApplications.DTOs;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.CorporateApplications.Queries;

public record GetCorporateApplicationByIdQuery(Guid Id) : IRequest<CorporateApplicationDto>;

public class GetCorporateApplicationByIdQueryHandler : IRequestHandler<GetCorporateApplicationByIdQuery, CorporateApplicationDto>
{
    private readonly IApplicationDbContext _context;
    public GetCorporateApplicationByIdQueryHandler(IApplicationDbContext context) => _context = context;

    public async Task<CorporateApplicationDto> Handle(GetCorporateApplicationByIdQuery request, CancellationToken ct)
    {
        var a = await _context.CorporateApplications
            .Include(x => x.ReviewedByUser)
            .FirstOrDefaultAsync(x => x.Id == request.Id, ct)
            ?? throw new NotFoundException("CorporateApplication", request.Id);

        return new CorporateApplicationDto(
            a.Id, a.CompanyName, a.OrgNumber, a.ContactName, a.ContactEmail,
            a.ContactPhone, a.DocumentPaths, a.DocumentsJson, a.Status.ToString(),
            a.ReviewNote, a.ReviewedAt,
            a.ReviewedByUser?.FullName, a.ResubmitCount, a.PhoneVerified, a.CreatedAt);
    }
}

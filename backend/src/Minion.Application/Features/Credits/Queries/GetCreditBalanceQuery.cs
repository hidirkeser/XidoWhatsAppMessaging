using MediatR;
using Minion.Application.Features.Credits.DTOs;
using Minion.Domain.Interfaces;

namespace Minion.Application.Features.Credits.Queries;

public record GetCreditBalanceQuery : IRequest<CreditBalanceDto>;

public class GetCreditBalanceQueryHandler : IRequestHandler<GetCreditBalanceQuery, CreditBalanceDto>
{
    private readonly ICreditService _creditService;
    private readonly ICurrentUserService _currentUser;

    public GetCreditBalanceQueryHandler(ICreditService creditService, ICurrentUserService currentUser)
    {
        _creditService = creditService;
        _currentUser = currentUser;
    }

    public async Task<CreditBalanceDto> Handle(GetCreditBalanceQuery request, CancellationToken ct)
    {
        var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();
        var balance = await _creditService.GetBalanceAsync(userId, ct);
        return new CreditBalanceDto(balance);
    }
}

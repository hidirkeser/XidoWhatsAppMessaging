using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Minion.Domain.Entities;
using Minion.Domain.Exceptions;
using Minion.Infrastructure.Persistence;
using Minion.Infrastructure.Services;

namespace Minion.Application.Tests.Features.Credits;

public class CreditServiceTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly CreditService _service;
    private readonly Guid _userId = Guid.NewGuid();

    public CreditServiceTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        _context = new ApplicationDbContext(options);
        _service = new CreditService(_context);

        _context.Users.Add(new User { Id = _userId, PersonalNumber = "199001011234", FirstName = "Test", LastName = "User" });
        _context.UserCredits.Add(new UserCredit { Id = Guid.NewGuid(), UserId = _userId, Balance = 50 });
        _context.SaveChanges();
    }

    [Fact]
    public async Task GetBalance_ShouldReturn_CorrectBalance()
    {
        var balance = await _service.GetBalanceAsync(_userId);
        balance.Should().Be(50);
    }

    [Fact]
    public async Task HasSufficientCredits_ShouldReturn_True_WhenEnough()
    {
        var result = await _service.HasSufficientCreditsAsync(_userId, 30);
        result.Should().BeTrue();
    }

    [Fact]
    public async Task HasSufficientCredits_ShouldReturn_False_WhenNotEnough()
    {
        var result = await _service.HasSufficientCreditsAsync(_userId, 100);
        result.Should().BeFalse();
    }

    [Fact]
    public async Task AddCredits_ShouldIncrease_Balance()
    {
        var packageId = Guid.NewGuid();
        await _service.AddCreditsAsync(_userId, 20, packageId, _userId);

        var balance = await _service.GetBalanceAsync(_userId);
        balance.Should().Be(70);
    }

    [Fact]
    public async Task AddCredits_ShouldCreate_Transaction()
    {
        var packageId = Guid.NewGuid();
        await _service.AddCreditsAsync(_userId, 20, packageId, _userId);

        var tx = await _context.CreditTransactions.FirstOrDefaultAsync(t => t.UserId == _userId);
        tx.Should().NotBeNull();
        tx!.Amount.Should().Be(20);
        tx.BalanceAfter.Should().Be(70);
    }

    [Fact]
    public async Task ManualAdjust_Positive_ShouldIncrease()
    {
        await _service.ManualAdjustAsync(_userId, 10, "Bonus", _userId);
        var balance = await _service.GetBalanceAsync(_userId);
        balance.Should().Be(60);
    }

    [Fact]
    public async Task ManualAdjust_Negative_ShouldDecrease()
    {
        await _service.ManualAdjustAsync(_userId, -5, "Correction", _userId);
        var balance = await _service.GetBalanceAsync(_userId);
        balance.Should().Be(45);
    }

    [Fact]
    public async Task RefundAsync_ShouldIncrease_Balance()
    {
        var delegationId = Guid.NewGuid();
        await _service.RefundAsync(_userId, 10, delegationId, _userId);
        var balance = await _service.GetBalanceAsync(_userId);
        balance.Should().Be(60);
    }

    public void Dispose() => _context.Dispose();
}

using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Delegations.Commands;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Exceptions;
using Minion.Domain.Interfaces;
using Minion.Infrastructure.Persistence;
using Minion.Infrastructure.Services;
using Moq;

namespace Minion.Application.Tests.Features.Delegations;

public class CreateDelegationCommandTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly Mock<ICreditService> _creditService;
    private readonly Mock<IAuditLogService> _auditService;
    private readonly Mock<INotificationService> _notificationService;
    private readonly Mock<ICurrentUserService> _currentUserService;
    private readonly CreateDelegationCommandHandler _handler;

    private readonly Guid _grantorId = Guid.NewGuid();
    private readonly Guid _delegateId = Guid.NewGuid();
    private readonly Guid _orgId = Guid.NewGuid();
    private readonly Guid _opTypeId = Guid.NewGuid();

    public CreateDelegationCommandTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        _context = new ApplicationDbContext(options);
        _creditService = new Mock<ICreditService>();
        _auditService = new Mock<IAuditLogService>();
        _notificationService = new Mock<INotificationService>();
        _currentUserService = new Mock<ICurrentUserService>();

        _currentUserService.Setup(x => x.UserId).Returns(_grantorId);

        SeedData();

        _handler = new CreateDelegationCommandHandler(
            _context, _currentUserService.Object, _creditService.Object,
            _auditService.Object, _notificationService.Object);
    }

    private void SeedData()
    {
        _context.Users.AddRange(
            new User { Id = _grantorId, PersonalNumber = "199001011234", FirstName = "Grantor", LastName = "User", IsActive = true },
            new User { Id = _delegateId, PersonalNumber = "199505051234", FirstName = "Delegate", LastName = "User", IsActive = true }
        );
        _context.Organizations.Add(new Organization { Id = _orgId, Name = "Test Org", OrgNumber = "1234567890", CreatedByUserId = _grantorId });
        _context.OperationTypes.Add(new OperationType { Id = _opTypeId, OrganizationId = _orgId, Name = "Sign", CreditCost = 2, IsActive = true });
        _context.SaveChanges();
    }

    [Fact]
    public async Task Should_CreateDelegation_WhenValid()
    {
        _creditService.Setup(x => x.HasSufficientCreditsAsync(_grantorId, 2, It.IsAny<CancellationToken>())).ReturnsAsync(true);

        var command = new CreateDelegationCommand(_delegateId, _orgId, new List<Guid> { _opTypeId }, "hours", 1, null, null, null);

        var result = await _handler.Handle(command, CancellationToken.None);

        result.Should().NotBeNull();
        result.Status.Should().Be("PendingApproval");
        result.GrantorName.Should().Be("Grantor User");
        result.DelegateName.Should().Be("Delegate User");

        _creditService.Verify(x => x.DeductAsync(_grantorId, 2, It.IsAny<Guid>(), _grantorId, It.IsAny<CancellationToken>()), Times.Once);
        _notificationService.Verify(x => x.SendAsync(_delegateId, It.IsAny<string>(), It.IsAny<string>(),
            NotificationType.DelegationGranted, It.IsAny<Guid>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Should_ThrowException_WhenDelegatingToSelf()
    {
        var command = new CreateDelegationCommand(_grantorId, _orgId, new List<Guid> { _opTypeId }, "hours", 1, null, null, null);

        var act = async () => await _handler.Handle(command, CancellationToken.None);

        await act.Should().ThrowAsync<DomainException>().WithMessage("*yourself*");
    }

    [Fact]
    public async Task Should_ThrowException_WhenInsufficientCredits()
    {
        _creditService.Setup(x => x.HasSufficientCreditsAsync(_grantorId, 2, It.IsAny<CancellationToken>())).ReturnsAsync(false);
        _creditService.Setup(x => x.GetBalanceAsync(_grantorId, It.IsAny<CancellationToken>())).ReturnsAsync(0);

        var command = new CreateDelegationCommand(_delegateId, _orgId, new List<Guid> { _opTypeId }, "hours", 1, null, null, null);

        var act = async () => await _handler.Handle(command, CancellationToken.None);

        await act.Should().ThrowAsync<InsufficientCreditsException>();
    }

    [Fact]
    public async Task Should_ThrowException_WhenDelegateUserNotFound()
    {
        var command = new CreateDelegationCommand(Guid.NewGuid(), _orgId, new List<Guid> { _opTypeId }, "hours", 1, null, null, null);

        var act = async () => await _handler.Handle(command, CancellationToken.None);

        await act.Should().ThrowAsync<NotFoundException>();
    }

    public void Dispose() => _context.Dispose();
}

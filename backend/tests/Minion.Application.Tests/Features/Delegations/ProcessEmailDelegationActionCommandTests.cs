using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Minion.Application.Features.Delegations.Commands;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;
using Minion.Infrastructure.Persistence;
using Moq;

namespace Minion.Application.Tests.Features.Delegations;

public class ProcessEmailDelegationActionCommandTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly Mock<ICreditService>       _creditService;
    private readonly Mock<IAuditLogService>     _auditService;
    private readonly Mock<INotificationService> _notificationService;
    private readonly ProcessEmailDelegationActionCommandHandler _handler;

    private readonly Guid _grantorId  = Guid.NewGuid();
    private readonly Guid _delegateId = Guid.NewGuid();
    private readonly Guid _orgId      = Guid.NewGuid();
    private Delegation    _delegation = null!;

    public ProcessEmailDelegationActionCommandTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        _context             = new ApplicationDbContext(options);
        _creditService       = new Mock<ICreditService>();
        _auditService        = new Mock<IAuditLogService>();
        _notificationService = new Mock<INotificationService>();

        SeedData();

        _handler = new ProcessEmailDelegationActionCommandHandler(
            _context, _creditService.Object, _auditService.Object, _notificationService.Object);
    }

    private void SeedData()
    {
        var grantor = new User
        {
            Id             = _grantorId,
            PersonalNumber = "199001011111",
            FirstName      = "Ali",
            LastName       = "Grantor",
            IsActive       = true,
        };
        var delegate_ = new User
        {
            Id             = _delegateId,
            PersonalNumber = "199505052222",
            FirstName      = "Berk",
            LastName       = "Delegate",
            IsActive       = true,
        };
        var org = new Organization
        {
            Id               = _orgId,
            Name             = "Test Org",
            OrgNumber        = "5567890123",
            CreatedByUserId  = _grantorId,
        };

        _context.Users.AddRange(grantor, delegate_);
        _context.Organizations.Add(org);

        _delegation = new Delegation
        {
            Id              = Guid.NewGuid(),
            GrantorUserId   = _grantorId,
            DelegateUserId  = _delegateId,
            OrganizationId  = _orgId,
            Status          = DelegationStatus.PendingApproval,
            ValidFrom       = DateTime.UtcNow,
            ValidTo         = DateTime.UtcNow.AddDays(7),
            CreditsDeducted = 3,
        };
        _context.Delegations.Add(_delegation);
        _context.SaveChanges();
    }

    // ── Accept ────────────────────────────────────────────────────────────────

    [Fact]
    public async Task Accept_ValidToken_SetsStatusActive()
    {
        var command = new ProcessEmailDelegationActionCommand(_delegation.Id, _delegateId, "accept");

        var (success, title, _) = await _handler.Handle(command, CancellationToken.None);

        success.Should().BeTrue();
        title.Should().Contain("Kabul");

        var updated = await _context.Delegations.FindAsync(_delegation.Id);
        updated!.Status.Should().Be(DelegationStatus.Active);
        updated.AcceptedAt.Should().NotBeNull();
    }

    [Fact]
    public async Task Accept_NotifiesGrantor()
    {
        var command = new ProcessEmailDelegationActionCommand(_delegation.Id, _delegateId, "accept");

        await _handler.Handle(command, CancellationToken.None);

        _notificationService.Verify(x => x.SendAsync(
            _grantorId,
            It.IsAny<string>(),
            It.IsAny<string>(),
            NotificationType.DelegationAccepted,
            _delegation.Id,
            It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Accept_DoesNotRefundCredits()
    {
        var command = new ProcessEmailDelegationActionCommand(_delegation.Id, _delegateId, "accept");

        await _handler.Handle(command, CancellationToken.None);

        _creditService.Verify(x => x.RefundAsync(
            It.IsAny<Guid>(), It.IsAny<int>(), It.IsAny<Guid>(),
            It.IsAny<Guid>(), It.IsAny<CancellationToken>()), Times.Never);
    }

    // ── Reject ────────────────────────────────────────────────────────────────

    [Fact]
    public async Task Reject_ValidToken_SetsStatusRejected()
    {
        var command = new ProcessEmailDelegationActionCommand(_delegation.Id, _delegateId, "reject");

        var (success, title, _) = await _handler.Handle(command, CancellationToken.None);

        success.Should().BeTrue();
        title.Should().Contain("Reddedildi");

        var updated = await _context.Delegations.FindAsync(_delegation.Id);
        updated!.Status.Should().Be(DelegationStatus.Rejected);
        updated.RejectedAt.Should().NotBeNull();
    }

    [Fact]
    public async Task Reject_RefundsCreditsToGrantor()
    {
        var command = new ProcessEmailDelegationActionCommand(_delegation.Id, _delegateId, "reject");

        await _handler.Handle(command, CancellationToken.None);

        _creditService.Verify(x => x.RefundAsync(
            _grantorId,
            _delegation.CreditsDeducted,
            _delegation.Id,
            _delegateId,
            It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Reject_NotifiesGrantor()
    {
        var command = new ProcessEmailDelegationActionCommand(_delegation.Id, _delegateId, "reject");

        await _handler.Handle(command, CancellationToken.None);

        _notificationService.Verify(x => x.SendAsync(
            _grantorId,
            It.IsAny<string>(),
            It.IsAny<string>(),
            NotificationType.DelegationRejected,
            _delegation.Id,
            It.IsAny<CancellationToken>()), Times.Once);
    }

    // ── Security: wrong delegateUserId ────────────────────────────────────────

    [Fact]
    public async Task Process_WrongDelegateUserId_ReturnsUnauthorized()
    {
        var wrongUserId = Guid.NewGuid();
        var command     = new ProcessEmailDelegationActionCommand(_delegation.Id, wrongUserId, "accept");

        var (success, title, _) = await _handler.Handle(command, CancellationToken.None);

        success.Should().BeFalse();
        title.Should().Contain("Yetkisiz");

        // Delegation status must remain unchanged
        var updated = await _context.Delegations.FindAsync(_delegation.Id);
        updated!.Status.Should().Be(DelegationStatus.PendingApproval);
    }

    // ── Not found ─────────────────────────────────────────────────────────────

    [Fact]
    public async Task Process_DelegationNotFound_ReturnsNotFound()
    {
        var command = new ProcessEmailDelegationActionCommand(Guid.NewGuid(), _delegateId, "accept");

        var (success, title, _) = await _handler.Handle(command, CancellationToken.None);

        success.Should().BeFalse();
        title.Should().Contain("Bulunamadı");
    }

    // ── Already processed ─────────────────────────────────────────────────────

    [Theory]
    [InlineData(DelegationStatus.Active)]
    [InlineData(DelegationStatus.Rejected)]
    [InlineData(DelegationStatus.Revoked)]
    [InlineData(DelegationStatus.Expired)]
    public async Task Process_AlreadyProcessed_ReturnsFalse(DelegationStatus alreadyStatus)
    {
        _delegation.Status = alreadyStatus;
        await _context.SaveChangesAsync();

        var command = new ProcessEmailDelegationActionCommand(_delegation.Id, _delegateId, "accept");

        var (success, _, _) = await _handler.Handle(command, CancellationToken.None);

        success.Should().BeFalse();
    }

    public void Dispose() => _context.Dispose();
}

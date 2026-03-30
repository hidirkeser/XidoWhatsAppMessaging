using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Minion.Domain.Entities;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;
using Minion.Infrastructure.Persistence;
using Minion.Infrastructure.Services;
using Moq;

namespace Minion.Application.Tests.Features.Notifications;

public class NotificationServiceTests : IDisposable
{
    private readonly ApplicationDbContext       _context;
    private readonly Mock<INotificationHubService> _hub;
    private readonly Mock<IEmailService>           _email;
    private readonly Mock<IWhatsAppService>        _whatsApp;
    private readonly Mock<ISmsService>             _sms;
    private readonly Mock<IFcmService>             _fcm;
    private readonly IJwtTokenService              _jwt;
    private readonly IConfiguration                _config;
    private readonly NotificationService           _sut;

    private readonly Guid _grantorId  = Guid.NewGuid();
    private readonly Guid _delegateId = Guid.NewGuid();
    private readonly Guid _orgId      = Guid.NewGuid();

    public NotificationServiceTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        _context  = new ApplicationDbContext(options);
        _hub      = new Mock<INotificationHubService>();
        _email    = new Mock<IEmailService>();
        _whatsApp = new Mock<IWhatsAppService>();
        _sms      = new Mock<ISmsService>();
        _fcm      = new Mock<IFcmService>();

        _config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Jwt:Secret"]   = "test-notification-service-secret-key-xyz!",
                ["Jwt:Issuer"]   = "Minion",
                ["Jwt:Audience"] = "Minion",
                ["Jwt:AccessTokenExpiryMinutes"] = "15",
                ["AppBaseUrl"]   = "http://localhost:5131",
            })
            .Build();

        _jwt = new JwtTokenService(_config);

        _sut = new NotificationService(
            _context,
            _hub.Object,
            _email.Object,
            _whatsApp.Object,
            _sms.Object,
            _fcm.Object,
            _jwt,
            _config,
            NullLogger<NotificationService>.Instance);

        SeedData();
    }

    private void SeedData()
    {
        _context.Users.AddRange(
            new User { Id = _grantorId,  PersonalNumber = "199001011111", FirstName = "Ali",  LastName = "Veren",   IsActive = true, Email = "ali@example.com",  Phone = "0701234567" },
            new User { Id = _delegateId, PersonalNumber = "199505052222", FirstName = "Berk", LastName = "Atanan",  IsActive = true, Email = "berk@example.com", Phone = "0709876543" }
        );
        _context.Organizations.Add(new Organization
        {
            Id = _orgId, Name = "Org AB", OrgNumber = "5565555555", CreatedByUserId = _grantorId,
        });
        _context.SaveChanges();
    }

    private Delegation CreateAndSaveDelegation(Guid? id = null)
    {
        var opType = new OperationType
        {
            Id = Guid.NewGuid(), OrganizationId = _orgId, Name = "Sign", CreditCost = 2, IsActive = true,
        };
        _context.OperationTypes.Add(opType);

        var delegation = new Delegation
        {
            Id              = id ?? Guid.NewGuid(),
            GrantorUserId   = _grantorId,
            DelegateUserId  = _delegateId,
            OrganizationId  = _orgId,
            Status          = DelegationStatus.PendingApproval,
            ValidFrom       = DateTime.UtcNow,
            ValidTo         = DateTime.UtcNow.AddDays(7),
            CreditsDeducted = 2,
        };
        delegation.DelegationOperations.Add(new DelegationOperation
        {
            DelegationId   = delegation.Id,
            OperationTypeId = opType.Id,
            OperationType  = opType,
        });
        _context.Delegations.Add(delegation);
        _context.SaveChanges();
        return delegation;
    }

    // ── Notification persisted to DB ──────────────────────────────────────────

    [Fact]
    public async Task SendAsync_PersistsNotificationToDatabase()
    {
        var userId = _delegateId;

        await _sut.SendAsync(userId, "Test Title", "Test Body",
            NotificationType.DelegationAccepted, null);

        var saved = await _context.Notifications
            .FirstOrDefaultAsync(n => n.UserId == userId);

        saved.Should().NotBeNull();
        saved!.Title.Should().Be("Test Title");
        saved.Body.Should().Be("Test Body");
        saved.Type.Should().Be(NotificationType.DelegationAccepted);
    }

    // ── SignalR hub called ────────────────────────────────────────────────────

    [Fact]
    public async Task SendAsync_InvokesSignalRHub()
    {
        await _sut.SendAsync(_delegateId, "Hub Test", "Body",
            NotificationType.DelegationRejected, null);

        _hub.Verify(h => h.SendToUserAsync(
            _delegateId,
            "ReceiveNotification",
            It.IsAny<object>(),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    // ── FCM called for all notification types ─────────────────────────────────

    [Theory]
    [InlineData(NotificationType.DelegationAccepted)]
    [InlineData(NotificationType.DelegationRejected)]
    [InlineData(NotificationType.DelegationRevoked)]
    [InlineData(NotificationType.DelegationExpiringSoon)]
    [InlineData(NotificationType.LowCreditWarning)]
    [InlineData(NotificationType.CreditPurchaseSuccess)]
    public async Task SendAsync_CallsFcm_ForAllTypes(NotificationType type)
    {
        // Register a device token so FCM has something to send to
        _context.DeviceTokens.Add(new DeviceToken
        {
            Id       = Guid.NewGuid(),
            UserId   = _delegateId,
            Token    = "fcm-test-token",
            Platform = DevicePlatform.Android,
            IsActive = true,
        });
        await _context.SaveChangesAsync();

        await _sut.SendAsync(_delegateId, "Title", "Body", type, Guid.NewGuid());

        _fcm.Verify(f => f.SendAsync(
            It.Is<IEnumerable<string>>(t => t.Contains("fcm-test-token")),
            "Title",
            "Body",
            type.ToString(),
            It.IsAny<Guid?>(),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task SendAsync_NoDeviceTokens_FcmNotCalled()
    {
        // No device tokens registered for this user
        await _sut.SendAsync(_delegateId, "Title", "Body",
            NotificationType.DelegationAccepted, null);

        _fcm.Verify(f => f.SendAsync(
            It.IsAny<IEnumerable<string>>(),
            It.IsAny<string>(),
            It.IsAny<string>(),
            It.IsAny<string>(),
            It.IsAny<Guid?>(),
            It.IsAny<CancellationToken>()), Times.Never);
    }

    // ── Email + WhatsApp only for DelegationGranted ───────────────────────────

    [Fact]
    public async Task SendAsync_DelegationGranted_SendsEmailAndWhatsApp()
    {
        var delegation = CreateAndSaveDelegation();

        await _sut.SendAsync(_delegateId, "Yetki Talebi", "Detay",
            NotificationType.DelegationGranted, delegation.Id);

        _email.Verify(e => e.SendDelegationRequestAsync(
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<DateTime>(),
            It.IsAny<DateTime>(), It.IsAny<string?>(),
            It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<CancellationToken>()), Times.Once);

        _whatsApp.Verify(w => w.SendDelegationRequestAsync(
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<DateTime>(),
            It.IsAny<DateTime>(), It.IsAny<string?>(),
            It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task SendAsync_DelegationAccepted_DoesNotSendEmail()
    {
        await _sut.SendAsync(_delegateId, "Kabul", "Body",
            NotificationType.DelegationAccepted, Guid.NewGuid());

        _email.Verify(e => e.SendDelegationRequestAsync(
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<DateTime>(),
            It.IsAny<DateTime>(), It.IsAny<string?>(),
            It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<CancellationToken>()), Times.Never);

        _whatsApp.Verify(w => w.SendDelegationRequestAsync(
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<DateTime>(),
            It.IsAny<DateTime>(), It.IsAny<string?>(),
            It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<CancellationToken>()), Times.Never);
    }

    // ── Delegate has no email → email skipped ────────────────────────────────

    [Fact]
    public async Task SendAsync_DelegateHasNoEmail_EmailSkipped()
    {
        // Update delegate user: remove email
        var delegate_ = await _context.Users.FindAsync(_delegateId);
        delegate_!.Email = null;
        await _context.SaveChangesAsync();

        var delegation = CreateAndSaveDelegation();

        await _sut.SendAsync(_delegateId, "Title", "Body",
            NotificationType.DelegationGranted, delegation.Id);

        _email.Verify(e => e.SendDelegationRequestAsync(
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<DateTime>(),
            It.IsAny<DateTime>(), It.IsAny<string?>(),
            It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<CancellationToken>()), Times.Never);

        // WhatsApp should still be called (phone exists)
        _whatsApp.Verify(w => w.SendDelegationRequestAsync(
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<DateTime>(),
            It.IsAny<DateTime>(), It.IsAny<string?>(),
            It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    // ── Delegate has no phone → WhatsApp skipped ─────────────────────────────

    [Fact]
    public async Task SendAsync_DelegateHasNoPhone_WhatsAppSkipped()
    {
        var delegate_ = await _context.Users.FindAsync(_delegateId);
        delegate_!.Phone = null;
        await _context.SaveChangesAsync();

        var delegation = CreateAndSaveDelegation();

        await _sut.SendAsync(_delegateId, "Title", "Body",
            NotificationType.DelegationGranted, delegation.Id);

        _whatsApp.Verify(w => w.SendDelegationRequestAsync(
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<DateTime>(),
            It.IsAny<DateTime>(), It.IsAny<string?>(),
            It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<CancellationToken>()), Times.Never);

        // Email should still be called (email exists)
        _email.Verify(e => e.SendDelegationRequestAsync(
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<DateTime>(),
            It.IsAny<DateTime>(), It.IsAny<string?>(),
            It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    // ── External channel failure doesn't break main flow ─────────────────────

    [Fact]
    public async Task SendAsync_EmailThrows_NotificationStillSaved()
    {
        _email.Setup(e => e.SendDelegationRequestAsync(
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<string>(), It.IsAny<string>(), It.IsAny<DateTime>(),
            It.IsAny<DateTime>(), It.IsAny<string?>(),
            It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<CancellationToken>()))
            .ThrowsAsync(new Exception("SMTP error"));

        var delegation = CreateAndSaveDelegation();

        // Should not throw
        var act = async () => await _sut.SendAsync(
            _delegateId, "Title", "Body",
            NotificationType.DelegationGranted, delegation.Id);

        await act.Should().NotThrowAsync();

        // Notification was still persisted
        var saved = await _context.Notifications.AnyAsync(n => n.UserId == _delegateId);
        saved.Should().BeTrue();
    }

    public void Dispose() => _context.Dispose();
}

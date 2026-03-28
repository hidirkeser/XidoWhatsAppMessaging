using FluentAssertions;
using Microsoft.Extensions.Configuration;
using Minion.Infrastructure.Services;

namespace Minion.Domain.Tests.Services;

public class JwtTokenDelegationActionTests
{
    private readonly JwtTokenService _sut;

    public JwtTokenDelegationActionTests()
    {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Jwt:Secret"]  = "test-super-secret-key-min-32-chars-long!",
                ["Jwt:Issuer"]  = "Minion",
                ["Jwt:Audience"] = "Minion",
                ["Jwt:AccessTokenExpiryMinutes"] = "15",
            })
            .Build();

        _sut = new JwtTokenService(config);
    }

    // ── Generate + validate round-trip ────────────────────────────────────────

    [Fact]
    public void GenerateAndValidate_Accept_RoundTrip()
    {
        var delegationId   = Guid.NewGuid();
        var delegateUserId = Guid.NewGuid();

        var token  = _sut.GenerateDelegationActionToken(delegationId, delegateUserId, "accept");
        var result = _sut.ValidateDelegationActionToken(token);

        result.Valid.Should().BeTrue();
        result.DelegationId.Should().Be(delegationId);
        result.DelegateUserId.Should().Be(delegateUserId);
        result.Action.Should().Be("accept");
    }

    [Fact]
    public void GenerateAndValidate_Reject_RoundTrip()
    {
        var delegationId   = Guid.NewGuid();
        var delegateUserId = Guid.NewGuid();

        var token  = _sut.GenerateDelegationActionToken(delegationId, delegateUserId, "reject");
        var result = _sut.ValidateDelegationActionToken(token);

        result.Valid.Should().BeTrue();
        result.DelegationId.Should().Be(delegationId);
        result.DelegateUserId.Should().Be(delegateUserId);
        result.Action.Should().Be("reject");
    }

    [Fact]
    public void Generate_DifferentDelegations_ProduceDifferentTokens()
    {
        var userId = Guid.NewGuid();
        var token1 = _sut.GenerateDelegationActionToken(Guid.NewGuid(), userId, "accept");
        var token2 = _sut.GenerateDelegationActionToken(Guid.NewGuid(), userId, "accept");

        token1.Should().NotBe(token2);
    }

    // ── Security: tampered token ──────────────────────────────────────────────

    [Fact]
    public void Validate_TamperedToken_ReturnsFalse()
    {
        var token   = _sut.GenerateDelegationActionToken(Guid.NewGuid(), Guid.NewGuid(), "accept");
        var tampered = token[..^5] + " XXXXX"; // corrupt last 5 chars of signature

        var result = _sut.ValidateDelegationActionToken(tampered);

        result.Valid.Should().BeFalse();
        result.DelegationId.Should().Be(Guid.Empty);
        result.DelegateUserId.Should().Be(Guid.Empty);
        result.Action.Should().BeEmpty();
    }

    [Fact]
    public void Validate_EmptyString_ReturnsFalse()
    {
        var result = _sut.ValidateDelegationActionToken(string.Empty);

        result.Valid.Should().BeFalse();
    }

    [Fact]
    public void Validate_RandomGarbage_ReturnsFalse()
    {
        var result = _sut.ValidateDelegationActionToken("not.a.jwt");

        result.Valid.Should().BeFalse();
    }

    // ── Audience isolation: regular access token must not be accepted ─────────

    [Fact]
    public void Validate_RegularAccessToken_ReturnsFalse()
    {
        // A normal access token has audience "Minion", not "delegation-action"
        var user = new Minion.Domain.Entities.User
        {
            Id             = Guid.NewGuid(),
            PersonalNumber = "199001011234",
            FirstName      = "Test",
            LastName       = "User",
        };

        var accessToken = _sut.GenerateAccessToken(user);
        var result      = _sut.ValidateDelegationActionToken(accessToken);

        result.Valid.Should().BeFalse();
    }

    // ── Token signed with wrong secret ────────────────────────────────────────

    [Fact]
    public void Validate_TokenSignedWithDifferentSecret_ReturnsFalse()
    {
        var otherConfig = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Jwt:Secret"]  = "completely-different-secret-key-xyz-abc-def!",
                ["Jwt:Issuer"]  = "Minion",
                ["Jwt:Audience"] = "Minion",
            })
            .Build();

        var otherService = new JwtTokenService(otherConfig);
        var token        = otherService.GenerateDelegationActionToken(Guid.NewGuid(), Guid.NewGuid(), "accept");

        var result = _sut.ValidateDelegationActionToken(token);

        result.Valid.Should().BeFalse();
    }
}

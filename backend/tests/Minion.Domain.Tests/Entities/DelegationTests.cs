using FluentAssertions;
using Minion.Domain.Entities;
using Minion.Domain.Enums;

namespace Minion.Domain.Tests.Entities;

public class DelegationTests
{
    [Fact]
    public void NewDelegation_ShouldHave_PendingApprovalStatus()
    {
        var delegation = new Delegation();
        delegation.Status.Should().Be(DelegationStatus.PendingApproval);
    }

    [Fact]
    public void NewDelegation_ShouldHave_EmptyOperations()
    {
        var delegation = new Delegation();
        delegation.DelegationOperations.Should().BeEmpty();
    }

    [Fact]
    public void Delegation_CreatedAt_ShouldBeSet()
    {
        var before = DateTime.UtcNow;
        var delegation = new Delegation();
        delegation.CreatedAt.Should().BeOnOrAfter(before);
    }
}

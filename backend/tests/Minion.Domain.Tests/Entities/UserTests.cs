using FluentAssertions;
using Minion.Domain.Entities;

namespace Minion.Domain.Tests.Entities;

public class UserTests
{
    [Fact]
    public void FullName_ShouldCombine_FirstAndLastName()
    {
        var user = new User { FirstName = "Erik", LastName = "Svensson" };
        user.FullName.Should().Be("Erik Svensson");
    }

    [Fact]
    public void NewUser_ShouldBe_Active()
    {
        var user = new User();
        user.IsActive.Should().BeTrue();
    }

    [Fact]
    public void NewUser_ShouldNotBe_Admin()
    {
        var user = new User();
        user.IsAdmin.Should().BeFalse();
    }
}

using FluentAssertions;
using Minion.Infrastructure.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;

namespace Minion.Domain.Tests.Services;

public class BankIdQrCodeTests
{
    [Fact]
    public void GenerateQrCode_ShouldReturn_CorrectFormat()
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["BankId:BaseUrl"] = "https://appapi2.test.bankid.com/rp/v6.0/"
        }).Build();

        var service = new BankIdService(new HttpClient(), config, NullLogger<BankIdService>.Instance);

        var result = service.GenerateQrCode("test-token", "test-secret", 0);

        result.Should().StartWith("bankid.test-token.0.");
        result.Split('.').Should().HaveCount(4);
    }

    [Fact]
    public void GenerateQrCode_DifferentTime_ShouldProduceDifferentCodes()
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["BankId:BaseUrl"] = "https://appapi2.test.bankid.com/rp/v6.0/"
        }).Build();

        var service = new BankIdService(new HttpClient(), config, NullLogger<BankIdService>.Instance);

        var code0 = service.GenerateQrCode("token", "secret", 0);
        var code1 = service.GenerateQrCode("token", "secret", 1);

        code0.Should().NotBe(code1);
    }
}

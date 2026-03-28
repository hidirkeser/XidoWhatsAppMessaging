using FluentAssertions;
using Minion.Infrastructure.Helpers;

namespace Minion.Domain.Tests.Helpers;

public class PhoneNormalizerTests
{
    // ── Null / empty / whitespace ─────────────────────────────────────────────

    [Fact]
    public void Normalize_NullInput_ReturnsNull()
        => PhoneNormalizerHelper.Normalize(null).Should().BeNull();

    [Fact]
    public void Normalize_EmptyString_ReturnsNull()
        => PhoneNormalizerHelper.Normalize("").Should().BeNull();

    [Fact]
    public void Normalize_WhitespaceOnly_ReturnsNull()
        => PhoneNormalizerHelper.Normalize("   ").Should().BeNull();

    [Fact]
    public void Normalize_AllNonDigitNonPlus_ReturnsNull()
        => PhoneNormalizerHelper.Normalize("abc-xyz").Should().BeNull();

    // ── Already E.164 ─────────────────────────────────────────────────────────

    [Fact]
    public void Normalize_ValidE164_ReturnsSameValue()
        => PhoneNormalizerHelper.Normalize("+46701234567").Should().Be("+46701234567");

    [Fact]
    public void Normalize_E164WithSpaces_ReturnsStrippedE164()
        => PhoneNormalizerHelper.Normalize("+46 70 123 45 67").Should().Be("+46701234567");

    [Fact]
    public void Normalize_E164WithDashes_ReturnsStrippedE164()
        => PhoneNormalizerHelper.Normalize("+46-70-123-45-67").Should().Be("+46701234567");

    [Fact]
    public void Normalize_ShortE164_ReturnsSameValue()
        => PhoneNormalizerHelper.Normalize("+1234567").Should().Be("+1234567"); // exactly 8 chars

    [Fact]
    public void Normalize_TooShortE164_ReturnsNull()
        => PhoneNormalizerHelper.Normalize("+123456").Should().BeNull(); // 7 chars — too short

    // ── Swedish mobile (07XXXXXXXX → +467XXXXXXXX) ───────────────────────────

    [Fact]
    public void Normalize_SwedishMobile_ConvertsToE164()
        => PhoneNormalizerHelper.Normalize("0701234567").Should().Be("+46701234567");

    [Fact]
    public void Normalize_SwedishMobileWithSpaces_ConvertsToE164()
        => PhoneNormalizerHelper.Normalize("070 123 45 67").Should().Be("+46701234567");

    [Fact]
    public void Normalize_SwedishMobileWithDashes_ConvertsToE164()
        => PhoneNormalizerHelper.Normalize("070-123-45-67").Should().Be("+46701234567");

    [Fact]
    public void Normalize_SwedishMobileWrongLength_ReturnsNull()
        => PhoneNormalizerHelper.Normalize("070123456").Should().BeNull(); // 9 digits

    [Fact]
    public void Normalize_SwedishMobileTooLong_ReturnsNull()
        => PhoneNormalizerHelper.Normalize("07012345678").Should().BeNull(); // 11 digits

    // ── Country code without '+' ──────────────────────────────────────────────

    [Fact]
    public void Normalize_CountryCodeWithoutPlus_PrependsPlus()
        => PhoneNormalizerHelper.Normalize("46701234567").Should().Be("+46701234567");

    [Fact]
    public void Normalize_USNumberWithoutPlus_PrependsPlus()
        => PhoneNormalizerHelper.Normalize("12125551234").Should().Be("+12125551234");

    // ── Edge cases ────────────────────────────────────────────────────────────

    [Fact]
    public void Normalize_LocalNumberStartingWithZeroNotSwedish_ReturnsNull()
        => PhoneNormalizerHelper.Normalize("0812345678").Should().BeNull(); // starts with 0 but not "07"

    [Fact]
    public void Normalize_NumberWithMixedSeparators_ReturnsNormalized()
        => PhoneNormalizerHelper.Normalize("+46 70-123 45 67").Should().Be("+46701234567");
}

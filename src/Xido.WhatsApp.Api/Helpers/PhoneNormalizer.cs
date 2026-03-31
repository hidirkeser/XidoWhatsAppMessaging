using System.Text.RegularExpressions;

namespace Xido.WhatsApp.Api.Helpers;

public static partial class PhoneNormalizer
{
    [GeneratedRegex(@"[^\d+]")]
    private static partial Regex NonDigitRegex();

    /// <summary>
    /// Normalizes a phone number to E.164 format (e.g. +46701234567).
    /// Returns null if the number is too short or invalid.
    /// </summary>
    public static string? Normalize(string? input)
    {
        if (string.IsNullOrWhiteSpace(input))
            return null;

        var cleaned = NonDigitRegex().Replace(input.Trim(), "");

        // Restore leading '+' if it was there
        if (input.TrimStart().StartsWith('+'))
            cleaned = "+" + cleaned;

        // Must have at least 7 digits
        var digits = cleaned.TrimStart('+');
        if (digits.Length < 7)
            return null;

        // Ensure + prefix
        return cleaned.StartsWith('+') ? cleaned : "+" + cleaned;
    }
}

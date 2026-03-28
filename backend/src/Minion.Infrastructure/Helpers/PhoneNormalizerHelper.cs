namespace Minion.Infrastructure.Helpers;

/// <summary>
/// Normalizes phone numbers to E.164 format (+XXXXXXXXXXX).
/// Handles Swedish mobile numbers, numbers with spaces/dashes, and international formats.
/// </summary>
public static class PhoneNormalizerHelper
{
    /// <summary>
    /// Normalizes a phone number to E.164 (+XXXXXXXXX) format.
    /// Returns null if the number cannot be normalized.
    /// </summary>
    /// <remarks>
    /// Supported input formats:
    ///   +46 70 123 45 67  →  +46701234567  (E.164 with spaces)
    ///   +46701234567      →  +46701234567  (already E.164)
    ///   0701234567        →  +46701234567  (Swedish mobile 10-digit)
    ///   46701234567       →  +46701234567  (no leading +)
    ///   070-123-45-67     →  +46701234567  (dashes)
    /// </remarks>
    public static string? Normalize(string? phone)
    {
        if (string.IsNullOrWhiteSpace(phone)) return null;

        // Keep only '+' and digits
        var cleaned = new string(phone.Where(c => c == '+' || char.IsDigit(c)).ToArray());

        if (string.IsNullOrEmpty(cleaned)) return null;

        // Already E.164: starts with '+', at least 8 chars total (country code + number)
        if (cleaned.StartsWith('+') && cleaned.Length >= 8)
            return cleaned;

        // Swedish mobile: 07XXXXXXXX → +467XXXXXXXX (10 digits, starts with 07)
        if (cleaned.StartsWith("07") && cleaned.Length == 10)
            return "+46" + cleaned[1..];

        // Has country code but no '+': e.g. 46701234567
        if (!cleaned.StartsWith('0') && cleaned.Length >= 10)
            return "+" + cleaned;

        return null;
    }
}

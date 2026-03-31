using System.Globalization;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Minion.Domain.Enums;
using Minion.Domain.Interfaces;
using Minion.Infrastructure.Helpers;
using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Twilio.Types;

namespace Minion.Infrastructure.Services;

/// <summary>
/// WhatsApp notification via Twilio API.
///
/// Format seçimi admin panelinden yapılır (AppSetting: WhatsApp:CardFormat).
///   0 = ImageCard (SkiaSharp PNG kart — default)
///   1 = PlainText (düz metin)
///
/// Dev mode (WhatsApp:Enabled=false):
///   Mesaj body'sini console'a yazar — Twilio hesabı gerekmez.
///
/// Sandbox test (WhatsApp:Enabled=true + sandbox):
///   Alıcı telefonun "join {keyword}" mesajını +14155238886'ya göndermesi gerekir.
/// </summary>
public class TwilioWhatsAppService : IWhatsAppService
{
    private readonly IConfiguration      _config;
    private readonly ICardImageService   _cardImageService;
    private readonly IApplicationDbContext _context;
    private readonly ILogger<TwilioWhatsAppService> _logger;

    // Kart verisini kısa süreli bellekte tutar (Twilio fetch edene kadar)
    private static readonly System.Collections.Concurrent.ConcurrentDictionary<string, byte[]>
        _imageCache = new();

    public TwilioWhatsAppService(
        IConfiguration config,
        ICardImageService cardImageService,
        IApplicationDbContext context,
        ILogger<TwilioWhatsAppService> logger)
    {
        _config           = config;
        _cardImageService = cardImageService;
        _context          = context;
        _logger           = logger;
    }

    // ── Basit mesaj ──────────────────────────────────────────────────────────

    public async Task SendAsync(string toPhone, string message, CancellationToken ct = default)
    {
        var phone = PhoneNormalizerHelper.Normalize(toPhone);
        if (phone == null)
        {
            _logger.LogWarning("[WHATSAPP] Skipped — invalid phone: '{Phone}'", toPhone);
            return;
        }

        if (!IsEnabled())
        {
            _logger.LogInformation("[WHATSAPP-DEV] To: {Phone}\n{Body}", phone, message);
            return;
        }

        await SendTwilioAsync(phone, message, null, ct);
    }

    // ── Yetki talebi mesajı ──────────────────────────────────────────────────

    public async Task SendDelegationRequestAsync(
        string toPhone, string toName, string grantorName, string orgName,
        string operationNames, DateTime validFrom, DateTime validTo, string? notes,
        string acceptUrl, string rejectUrl, CancellationToken ct = default)
    {
        var phone = PhoneNormalizerHelper.Normalize(toPhone);
        if (phone == null)
        {
            _logger.LogWarning("[WHATSAPP] Skipped — invalid phone: '{Phone}'", toPhone);
            return;
        }

        var websiteUrl = GetWebsiteUrl();
        var format     = await GetCardFormatAsync(ct);
        var body       = BuildPlainText(toName, grantorName, orgName, operationNames, validFrom, validTo, notes, websiteUrl);

        if (!IsEnabled())
        {
            _logger.LogInformation("[WHATSAPP-DEV] Format={Format} To: {Phone}\n{Body}", format, phone, body);
            return;
        }

        string? mediaUrl = null;

        if (format == WhatsAppCardFormat.ImageCard)
        {
            mediaUrl = await BuildCardImageUrlAsync(
                grantorName, toName, orgName, operationNames, validFrom, validTo, notes, websiteUrl, ct);
        }

        await SendTwilioAsync(phone, body, mediaUrl, ct);
    }

    // ── Kart görsel URL'si oluştur ───────────────────────────────────────────

    private async Task<string?> BuildCardImageUrlAsync(
        string grantorName, string delegateName, string orgName,
        string operationNames, DateTime validFrom, DateTime validTo,
        string? notes, string websiteUrl, CancellationToken ct)
    {
        try
        {
            var pngBytes = _cardImageService.GenerateDelegationCard(
                grantorName, delegateName, orgName,
                operationNames, validFrom, validTo, notes, websiteUrl);

            var token = Guid.NewGuid().ToString("N");
            _imageCache[token] = pngBytes;

            // 10 dakika sonra temizle
            var tokenCopy = token;
            _ = Task.Delay(TimeSpan.FromMinutes(10), CancellationToken.None)
                    .ContinueWith(_ => { _imageCache.TryRemove(tokenCopy, out byte[] _); }, CancellationToken.None);

            var baseUrl = _config["AppBaseUrl"]?.TrimEnd('/') ?? "http://localhost:5131";
            return $"{baseUrl}/api/notifications/card/{token}.png";
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[WHATSAPP] Card image generation failed — falling back to plain text");
            return null;
        }
    }

    // ── İç cache'den PNG döndür (controller tarafından çağrılır) ────────────

    public static byte[]? GetCachedImage(string token) =>
        _imageCache.TryGetValue(token, out var data) ? data : null;

    // ── Twilio API ───────────────────────────────────────────────────────────

    private async Task SendTwilioAsync(
        string toPhone, string body, string? mediaUrl, CancellationToken ct)
    {
        var accountSid = _config["WhatsApp:AccountSid"]
            ?? throw new InvalidOperationException("WhatsApp:AccountSid not configured");
        var authToken = _config["WhatsApp:AuthToken"]
            ?? throw new InvalidOperationException("WhatsApp:AuthToken not configured");
        var from = _config["WhatsApp:From"] ?? "whatsapp:+14155238886";

        TwilioClient.Init(accountSid, authToken);

        var createParams = new CreateMessageOptions(new PhoneNumber($"whatsapp:{toPhone}"))
        {
            From = new PhoneNumber(from),
            Body = body,
        };

        if (!string.IsNullOrWhiteSpace(mediaUrl))
            createParams.MediaUrl = new List<Uri> { new(mediaUrl) };

        var msg = await MessageResource.CreateAsync(createParams);

        _logger.LogInformation("[WHATSAPP] Sent to {Phone}. SID: {Sid}, Status: {Status}",
            toPhone, msg.Sid, msg.Status);
    }

    // ── Yardımcılar ──────────────────────────────────────────────────────────

    private bool IsEnabled() => string.Equals(
        _config["WhatsApp:Enabled"], "true", StringComparison.OrdinalIgnoreCase);

    private string GetWebsiteUrl()
    {
        var url = _config["WebsiteUrl"]?.TrimEnd('/') ?? "https://minion.se";
        return url.StartsWith("http", StringComparison.OrdinalIgnoreCase) ? url : $"https://{url}";
    }

    private async Task<WhatsAppCardFormat> GetCardFormatAsync(CancellationToken ct)
    {
        var setting = await _context.AppSettings
            .FirstOrDefaultAsync(s => s.Key == "WhatsApp:CardFormat", ct);

        if (setting != null && int.TryParse(setting.Value, out var v))
            return (WhatsAppCardFormat)v;

        return WhatsAppCardFormat.ImageCard; // default
    }

    private static string BuildPlainText(
        string toName, string grantorName, string orgName, string operationNames,
        DateTime validFrom, DateTime validTo, string? notes, string websiteUrl)
    {
        var sb = new StringBuilder();
        sb.AppendLine("⚡ *Minion – Yeni Yetki Talebi*");
        sb.AppendLine();
        sb.AppendLine($"Merhaba *{toName}*,");
        sb.AppendLine();
        sb.AppendLine($"*{grantorName}* sizi *{orgName}* kurumunda yetkilendirmek istiyor.");
        sb.AppendLine();
        sb.AppendLine($"📋 *İşlemler:* {operationNames}");
        sb.AppendLine($"📅 *Geçerlilik:* {validFrom.ToString("dd.MM.yyyy HH:mm", CultureInfo.InvariantCulture)} – {validTo.ToString("dd.MM.yyyy HH:mm", CultureInfo.InvariantCulture)}");
        if (!string.IsNullOrWhiteSpace(notes))
            sb.AppendLine($"📝 *Not:* {notes}");
        sb.AppendLine();
        sb.AppendLine("👉 Kabul veya reddetmek için Minion uygulamasını açın.");
        sb.AppendLine();
        sb.AppendLine($"🌐 {websiteUrl}");
        return sb.ToString().TrimEnd();
    }
}

using System.Globalization;
using Minion.Domain.Interfaces;
using SkiaSharp;

namespace Minion.Infrastructure.Services;

/// <summary>
/// SkiaSharp kullanarak WhatsApp için PNG yetki kartı üretir.
/// Harici bağımlılık yok — Alpine Linux üzerinde çalışır.
/// </summary>
public class SkiaSharpCardImageService : ICardImageService
{
    private const int W = 480;

    // ── Renkler ──────────────────────────────────────────────
    private static readonly SKColor BgTop       = SKColor.Parse("#1A1A2E");
    private static readonly SKColor BgBottom    = SKColor.Parse("#16213E");
    private static readonly SKColor AccentColor = SKColor.Parse("#C5A028");
    private static readonly SKColor CardBg      = SKColor.Parse("#0F3460");
    private static readonly SKColor White       = SKColors.White;
    private static readonly SKColor Muted       = SKColor.Parse("#A0AEC0");
    private static readonly SKColor Gold        = SKColor.Parse("#FFD700");

    public byte[] GenerateDelegationCard(
        string grantorName, string delegateName, string orgName,
        string operationNames, DateTime validFrom, DateTime validTo, string? notes)
    {
        // ── Satırlar ─────────────────────────────────────────
        var rows = new List<(string label, string value)>
        {
            ("Yetki Veren",  grantorName),
            ("Yetki Verilen", delegateName),
            ("Kurum",        orgName),
            ("Yetkiler",     operationNames),
            ("Geçerlilik",   $"{validFrom:dd.MM.yyyy HH:mm} – {validTo:dd.MM.yyyy HH:mm}"),
        };
        if (!string.IsNullOrWhiteSpace(notes))
            rows.Add(("Not", notes!));

        // ── Yükseklik hesapla ────────────────────────────────
        const int paddingTop    = 60;
        const int headerH       = 80;
        const int dividerH      = 2;
        const int rowH          = 58;
        const int footerH       = 72;
        const int paddingBottom = 24;
        int bodyH = rows.Count * rowH;
        int H = paddingTop + headerH + dividerH + 12 + bodyH + footerH + paddingBottom;

        using var bmp    = new SKBitmap(W, H);
        using var canvas = new SKCanvas(bmp);

        // ── Arkaplan gradyanı ────────────────────────────────
        using (var bgPaint = new SKPaint())
        {
            bgPaint.Shader = SKShader.CreateLinearGradient(
                new SKPoint(0, 0), new SKPoint(0, H),
                new[] { BgTop, BgBottom }, null,
                SKShaderTileMode.Clamp);
            canvas.DrawRect(0, 0, W, H, bgPaint);
        }

        // ── Logo + başlık ────────────────────────────────────
        int y = paddingTop;
        DrawText(canvas, "⚡ Minion", 24, W / 2f, y, AccentColor, bold: true, center: true);
        y += 30;
        DrawText(canvas, "Yeni Yetki Talebi", 15, W / 2f, y, Muted, center: true);
        y += headerH - 30;

        // ── Altın çizgi ──────────────────────────────────────
        using (var linePaint = new SKPaint { Color = Gold, StrokeWidth = 2, IsAntialias = true })
            canvas.DrawLine(32, y, W - 32, y, linePaint);
        y += 14;

        // ── Satırlar ─────────────────────────────────────────
        foreach (var (label, value) in rows)
        {
            DrawText(canvas, label.ToUpperInvariant(), 10, 32, y, Muted, bold: true);
            y += 16;
            DrawText(canvas, value, 14, 32, y, White);
            y += rowH - 16;
        }

        // ── Alt bilgi ────────────────────────────────────────
        using (var linePaint = new SKPaint { Color = CardBg, StrokeWidth = 1 })
            canvas.DrawLine(32, y, W - 32, y, linePaint);
        y += 14;
        DrawText(canvas, "Kabul veya reddetmek için Minion uygulamasını açın.", 12, W / 2f, y, Muted, center: true);
        y += 20;
        DrawText(canvas, "minion.se", 11, W / 2f, y, AccentColor, center: true);

        // ── PNG encode ───────────────────────────────────────
        using var img  = SKImage.FromBitmap(bmp);
        using var data = img.Encode(SKEncodedImageFormat.Png, 90);
        return data.ToArray();
    }

    // ── Yardımcı: metin çiz ──────────────────────────────────
    private static void DrawText(
        SKCanvas canvas, string text, float size,
        float x, float y, SKColor color,
        bool bold = false, bool center = false)
    {
        using var paint = new SKPaint
        {
            Color       = color,
            TextSize    = size,
            IsAntialias = true,
            Typeface    = SKTypeface.FromFamilyName(
                              "Arial",
                              bold ? SKFontStyle.Bold : SKFontStyle.Normal),
            TextAlign   = center ? SKTextAlign.Center : SKTextAlign.Left,
        };
        // Uzun metinleri sar
        if (!center && paint.MeasureText(text) > W - 64)
        {
            var words = text.Split(' ');
            var line  = string.Empty;
            float lineY = y;
            foreach (var word in words)
            {
                var test = string.IsNullOrEmpty(line) ? word : line + " " + word;
                if (paint.MeasureText(test) > W - 64 && !string.IsNullOrEmpty(line))
                {
                    canvas.DrawText(line, x, lineY, paint);
                    lineY += size + 4;
                    line = word;
                }
                else
                {
                    line = test;
                }
            }
            if (!string.IsNullOrEmpty(line))
                canvas.DrawText(line, x, lineY, paint);
        }
        else
        {
            canvas.DrawText(text, x, y, paint);
        }
    }
}

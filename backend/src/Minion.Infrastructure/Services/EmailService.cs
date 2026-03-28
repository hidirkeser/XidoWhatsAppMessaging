using System.Globalization;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MimeKit;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services;

/// <summary>
/// Email service for sending delegation request notifications.
///
/// Dev mode (Email:Enabled=false):
///   Saves the HTML email to a temp file and logs the path.
///   Open the file in your browser to preview the email.
///
/// Prod mode (Email:Enabled=true):
///   Sends via SMTP using MailKit. Configure Email:SmtpHost, SmtpPort etc.
///   For local testing with Mailpit: docker run -p 1025:1025 -p 8025:8025 axllent/mailpit
/// </summary>
public class EmailService : IEmailService
{
    private readonly IConfiguration _config;
    private readonly ILogger<EmailService> _logger;

    public EmailService(IConfiguration config, ILogger<EmailService> logger)
    {
        _config = config;
        _logger = logger;
    }

    public async Task SendDelegationRequestAsync(
        string toEmail, string toName, string grantorName, string orgName,
        string operationNames, DateTime validFrom, DateTime validTo, string? notes,
        string acceptUrl, string rejectUrl, CancellationToken ct = default)
    {
        var subject = $"[Minion] {grantorName} sizi {orgName} için yetkilendirmek istiyor";
        var html = BuildHtml(toName, grantorName, orgName, operationNames,
            validFrom, validTo, notes, acceptUrl, rejectUrl);

        var enabled = _config["Email:Enabled"] == "true";

        if (!enabled)
        {
            // Dev mode: write to temp file so you can preview in browser
            var tmpPath = Path.Combine(Path.GetTempPath(), $"minion-email-{Guid.NewGuid():N}.html");
            await File.WriteAllTextAsync(tmpPath, html, ct);
            _logger.LogInformation(
                "[EMAIL-DEV] To: {To} | Subject: {Subject}\n→ Preview: {Path}",
                toEmail, subject, tmpPath);
            return;
        }

        var fromAddr = _config["Email:FromAddress"] ?? "noreply@minion.app";
        var fromName = _config["Email:FromName"] ?? "Minion";
        var host = _config["Email:SmtpHost"] ?? "localhost";
        var port = int.Parse(_config["Email:SmtpPort"] ?? "1025");
        var useTls = _config["Email:UseTls"] == "true";

        var message = new MimeMessage();
        message.From.Add(new MailboxAddress(fromName, fromAddr));
        message.To.Add(new MailboxAddress(toName, toEmail));
        message.Subject = subject;
        message.Body = new TextPart("html") { Text = html };

        using var client = new SmtpClient();
        var secureSocketOptions = useTls
            ? SecureSocketOptions.StartTls
            : SecureSocketOptions.None;

        await client.ConnectAsync(host, port, secureSocketOptions, ct);

        var user = _config["Email:SmtpUser"];
        var pass = _config["Email:SmtpPass"];
        if (!string.IsNullOrEmpty(user) && !string.IsNullOrEmpty(pass))
            await client.AuthenticateAsync(user, pass, ct);

        await client.SendAsync(message, ct);
        await client.DisconnectAsync(true, ct);

        _logger.LogInformation("[EMAIL] Sent delegation request to {To}", toEmail);
    }

    private static string BuildHtml(
        string toName, string grantorName, string orgName, string operationNames,
        DateTime validFrom, DateTime validTo, string? notes,
        string acceptUrl, string rejectUrl)
    {
        var notesRow = string.IsNullOrWhiteSpace(notes) ? "" : $"""
            <tr>
              <td style="padding:10px 0;border-bottom:1px solid #ede8e3;">
                <div style="color:#888;font-size:11px;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:3px;">Not</div>
                <div style="color:#1a1a2e;font-size:14px;">{notes}</div>
              </td>
            </tr>
            """;

        return $"""
            <!DOCTYPE html>
            <html lang="tr">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width,initial-scale=1.0">
              <title>Minion – Yetkilendirme Talebi</title>
            </head>
            <body style="margin:0;padding:0;background:#f2eeec;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
              <table width="100%" cellpadding="0" cellspacing="0" style="background:#f2eeec;padding:32px 0;">
                <tr><td align="center">
                  <table width="580" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:18px;overflow:hidden;box-shadow:0 6px 32px rgba(0,0,0,0.10);">

                    <!-- HEADER -->
                    <tr>
                      <td style="background:linear-gradient(135deg,#b76e79 0%,#c9956a 100%);padding:36px 40px;text-align:center;">
                        <div style="font-size:36px;font-weight:900;color:#fff;letter-spacing:-1px;">⚡ Minion</div>
                        <div style="color:rgba(255,255,255,0.82);font-size:13px;margin-top:4px;">Yetkilendirme Yönetim Platformu</div>
                      </td>
                    </tr>

                    <!-- BODY -->
                    <tr>
                      <td style="padding:36px 40px;">

                        <h2 style="margin:0 0 6px;color:#1a1a2e;font-size:20px;font-weight:800;">Merhaba {toName},</h2>
                        <p style="margin:0 0 24px;color:#555;font-size:15px;line-height:1.65;">
                          <strong style="color:#b76e79;">{grantorName}</strong>, sizi
                          <strong style="color:#1a1a2e;">{orgName}</strong> kurumunda
                          işlem yapmanız için yetkilendirmek istiyor.
                        </p>

                        <!-- DETAILS -->
                        <div style="background:#faf8f7;border:1px solid #ede8e3;border-radius:12px;padding:20px 24px;margin-bottom:28px;">
                          <table width="100%" cellpadding="0" cellspacing="0">
                            <tr>
                              <td style="padding:10px 0;border-bottom:1px solid #ede8e3;">
                                <div style="color:#888;font-size:11px;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:3px;">Kurum</div>
                                <div style="color:#1a1a2e;font-size:15px;font-weight:700;">{orgName}</div>
                              </td>
                            </tr>
                            <tr>
                              <td style="padding:10px 0;border-bottom:1px solid #ede8e3;">
                                <div style="color:#888;font-size:11px;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:3px;">İzin Verilen İşlemler</div>
                                <div style="color:#1a1a2e;font-size:14px;font-weight:600;">{operationNames}</div>
                              </td>
                            </tr>
                            <tr>
                              <td style="padding:10px 0;border-bottom:1px solid #ede8e3;">
                                <div style="color:#888;font-size:11px;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:3px;">Geçerlilik Süresi</div>
                                <div style="color:#1a1a2e;font-size:14px;font-weight:600;">
                                  {validFrom.ToString("dd.MM.yyyy HH:mm", CultureInfo.InvariantCulture)}
                                  &nbsp;–&nbsp;
                                  {validTo.ToString("dd.MM.yyyy HH:mm", CultureInfo.InvariantCulture)}
                                </div>
                              </td>
                            </tr>
                            {notesRow}
                          </table>
                        </div>

                        <!-- ACTION BUTTONS -->
                        <p style="margin:0 0 16px;color:#444;font-size:14px;">Bu talebi inceleyip kabul edebilir ya da reddedebilirsiniz:</p>
                        <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:28px;">
                          <tr>
                            <td width="48%" align="center">
                              <a href="{acceptUrl}"
                                 style="display:block;background:#22c55e;color:#fff;text-decoration:none;
                                        padding:14px;border-radius:10px;font-size:15px;font-weight:700;text-align:center;">
                                ✓ Kabul Et
                              </a>
                            </td>
                            <td width="4%"></td>
                            <td width="48%" align="center">
                              <a href="{rejectUrl}"
                                 style="display:block;background:#fff;color:#ef4444;text-decoration:none;
                                        padding:14px;border-radius:10px;font-size:15px;font-weight:700;
                                        border:2px solid #ef4444;text-align:center;">
                                ✗ Reddet
                              </a>
                            </td>
                          </tr>
                        </table>

                        <!-- WARNING -->
                        <div style="background:#fff8e6;border:1px solid #fde68a;border-radius:8px;padding:12px 16px;margin-bottom:28px;">
                          <p style="margin:0;color:#92400e;font-size:12px;line-height:1.5;">
                            ⚠️ Bu bağlantılar <strong>7 gün</strong> içinde geçerliliğini yitirir.
                            Yetki süresi dolduğunda otomatik olarak iptal edilir.
                            Talep tanıdık gelmiyor ise e-postayı görmezden gelebilirsiniz.
                          </p>
                        </div>

                        <!-- APP DOWNLOAD -->
                        <div style="border-top:1px solid #f0ebe6;padding-top:24px;">
                          <p style="margin:0 0 14px;color:#777;font-size:13px;text-align:center;">
                            Daha iyi bir deneyim için Minion uygulamasını indirin:
                          </p>
                          <table width="100%" cellpadding="0" cellspacing="0">
                            <tr>
                              <td width="48%" align="center">
                                <a href="https://apps.apple.com/app/minion"
                                   style="display:block;background:#000;color:#fff;text-decoration:none;
                                          padding:11px 16px;border-radius:10px;font-size:12px;font-weight:600;text-align:center;">
                                  🍎 App Store'dan İndir
                                </a>
                              </td>
                              <td width="4%"></td>
                              <td width="48%" align="center">
                                <a href="https://play.google.com/store/apps/details?id=com.minion.minion_app"
                                   style="display:block;background:#01875f;color:#fff;text-decoration:none;
                                          padding:11px 16px;border-radius:10px;font-size:12px;font-weight:600;text-align:center;">
                                  🤖 Google Play'den İndir
                                </a>
                              </td>
                            </tr>
                          </table>
                        </div>

                      </td>
                    </tr>

                    <!-- FOOTER -->
                    <tr>
                      <td style="background:#faf8f7;padding:18px 40px;text-align:center;border-top:1px solid #f0ebe6;">
                        <p style="margin:0;color:#aaa;font-size:11px;line-height:1.6;">
                          Bu e-postayı Minion platformundan bir yetkilendirme talebi nedeniyle alıyorsunuz.<br>
                          Güvenliğiniz için bu bağlantıları kimseyle paylaşmayın.
                        </p>
                      </td>
                    </tr>

                  </table>
                </td></tr>
              </table>
            </body>
            </html>
            """;
    }
}

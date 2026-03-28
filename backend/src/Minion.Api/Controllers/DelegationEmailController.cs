using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Minion.Application.Features.Delegations.Commands;
using Minion.Domain.Interfaces;

namespace Minion.Api.Controllers;

/// <summary>
/// Handles tokenized email action links (accept/reject) — no login required.
/// GET /api/delegations/email-action?token={jwt}
/// </summary>
[Route("api/delegations")]
[ApiController]
[AllowAnonymous]
public class DelegationEmailController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IJwtTokenService _jwt;

    public DelegationEmailController(IMediator mediator, IJwtTokenService jwt)
    {
        _mediator = mediator;
        _jwt = jwt;
    }

    [HttpGet("email-action")]
    [Produces("text/html")]
    public async Task<ContentResult> EmailAction([FromQuery] string token)
    {
        // 1. Validate token
        var (valid, delegationId, delegateUserId, action) =
            _jwt.ValidateDelegationActionToken(token ?? "");

        if (!valid)
        {
            return Content(BuildHtmlPage(
                success: false,
                title: "Geçersiz veya Süresi Dolmuş Bağlantı",
                message: "Bu bağlantı geçersiz ya da süresi dolmuş. " +
                         "Bağlantılar yalnızca 7 gün geçerlidir.",
                actionLabel: action), "text/html");
        }

        // 2. Process action
        var result = await _mediator.Send(
            new ProcessEmailDelegationActionCommand(delegationId, delegateUserId, action));

        return Content(BuildHtmlPage(
            success: result.Success,
            title: result.Title,
            message: result.Message,
            actionLabel: action), "text/html");
    }

    private static string BuildHtmlPage(bool success, string title, string message, string actionLabel)
    {
        var iconColor = success ? "#22c55e" : "#ef4444";
        var icon      = success ? "&#10003;" : "&#10007;";
        var bgColor   = success ? "#f0fdf4"  : "#fef2f2";

        const string appStoreUrl   = "https://apps.apple.com/app/minion";
        const string googlePlayUrl = "https://play.google.com/store/apps/details?id=com.minion.minion_app";

        // $$""" → literal { } are kept as-is; interpolations use {{expr}}
        return $$"""
            <!DOCTYPE html>
            <html lang="tr">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width,initial-scale=1.0">
              <title>Minion – {{title}}</title>
              <style>
                * { box-sizing: border-box; margin: 0; padding: 0; }
                body {
                  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                  background: #f2eeec;
                  min-height: 100vh;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  padding: 24px;
                }
                .card {
                  background: #fff;
                  border-radius: 20px;
                  box-shadow: 0 8px 40px rgba(0,0,0,0.12);
                  padding: 48px 40px;
                  max-width: 480px;
                  width: 100%;
                  text-align: center;
                }
                .icon-circle {
                  width: 80px; height: 80px;
                  border-radius: 50%;
                  background: {{bgColor}};
                  display: flex; align-items: center; justify-content: center;
                  margin: 0 auto 24px;
                  font-size: 36px;
                  color: {{iconColor}};
                  font-weight: 900;
                }
                .logo { font-size: 22px; font-weight: 900; color: #b76e79; margin-bottom: 32px; }
                h1 { font-size: 22px; font-weight: 800; color: #1a1a2e; margin-bottom: 12px; }
                p { color: #555; font-size: 15px; line-height: 1.6; margin-bottom: 32px; }
                .divider { border: none; border-top: 1px solid #f0ebe6; margin: 32px 0; }
                .download-label { color: #888; font-size: 13px; margin-bottom: 16px; }
                .btn-row { display: flex; gap: 12px; }
                .btn {
                  flex: 1; display: block; text-decoration: none;
                  padding: 12px; border-radius: 10px;
                  font-size: 12px; font-weight: 700; text-align: center;
                }
                .btn-ios { background: #000; color: #fff; }
                .btn-android { background: #01875f; color: #fff; }
              </style>
            </head>
            <body>
              <div class="card">
                <div class="logo">&#9889; Minion</div>
                <div class="icon-circle">{{icon}}</div>
                <h1>{{title}}</h1>
                <p>{{message}}</p>

                <hr class="divider">
                <p class="download-label">Minion uygulamasıyla tüm yetkilerinizi kolayca yönetin:</p>
                <div class="btn-row">
                  <a href="{{appStoreUrl}}" class="btn btn-ios">App Store</a>
                  <a href="{{googlePlayUrl}}" class="btn btn-android">Google Play</a>
                </div>
              </div>
            </body>
            </html>
            """;
    }
}

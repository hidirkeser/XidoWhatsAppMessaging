using Microsoft.AspNetCore.Mvc;
using Minion.Infrastructure.Services;

namespace Minion.Api.Controllers;

/// <summary>
/// Twilio'nun WhatsApp mesajına ekleyeceği PNG kart görselini döndürür.
/// Token geçici bir cache'ten okunur (10 dk TTL).
/// </summary>
[ApiController]
[Route("api/notifications")]
public class NotificationCardController : ControllerBase
{
    [HttpGet("card/{token}.png")]
    [ResponseCache(NoStore = true)]
    public IActionResult GetCard(string token)
    {
        var data = TwilioWhatsAppService.GetCachedImage(token);
        if (data == null)
            return NotFound();

        return File(data, "image/png");
    }
}

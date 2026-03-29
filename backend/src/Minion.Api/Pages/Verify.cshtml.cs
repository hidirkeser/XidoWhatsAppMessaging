using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Minion.Api.Pages;

public class VerifyModel : PageModel
{
    [BindProperty(SupportsGet = true)]
    public string Code { get; set; } = string.Empty;

    public void OnGet() { }
}

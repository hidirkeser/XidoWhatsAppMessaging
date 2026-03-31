namespace Minion.Domain.Entities;

/// <summary>
/// Admin tarafından yönetilebilen uygulama ayarları (key-value).
/// </summary>
public class AppSetting
{
    public string Key   { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;
}

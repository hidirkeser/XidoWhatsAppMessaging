/// Platform-specific BankID URL launcher.
///
/// Mobile/Desktop native → canLaunchUrl + LaunchMode.externalApplication
/// Web (Chrome on macOS)  → window.location.href (same tab, no blank window)
///                          macOS intercepts bankid:// scheme and opens BankID app.
export 'bankid_launcher_stub.dart'
    if (dart.library.html) 'bankid_launcher_web.dart';

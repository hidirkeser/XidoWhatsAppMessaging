// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web: set window.location.href so macOS intercepts bankid:// and opens the app.
/// Do NOT use window.open() — that creates a blank tab.
Future<bool> launchBankIdUrl(String url) async {
  html.window.location.href = url;
  return true;
}

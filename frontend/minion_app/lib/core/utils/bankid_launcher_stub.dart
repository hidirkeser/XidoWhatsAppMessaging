import 'package:url_launcher/url_launcher.dart';

/// Native (iOS / Android / macOS app): use canLaunchUrl + externalApplication.
Future<bool> launchBankIdUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await canLaunchUrl(uri)) return false;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
  return true;
}

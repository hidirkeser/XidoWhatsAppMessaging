import 'package:flutter/material.dart';
import '../widgets/app_dialog.dart';

// Keep this class for backward compatibility — delegates to AppDialog
class ApiErrorHandler {
  static Future<void> showError(BuildContext context, dynamic error) =>
      AppDialog.showError(context, error);

  static Future<void> showSuccess(BuildContext context, String message) =>
      AppDialog.showSuccess(context, message);
}

import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../services/error_code_translator.dart';
import 'quota_exhausted_dialog.dart';

enum DialogType { success, error, warning, info, confirm }

class AppDialog {
  // ── Show info / success / error / warning ─────────────────────────────────
  static Future<void> show(
    BuildContext context, {
    required DialogType type,
    required String message,
    String? title,
  }) {
    final s = AppL10n.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AppDialogWidget(
        type: type,
        title: title ?? _defaultTitle(type, s),
        message: message,
        confirmLabel: s.ok,
      ),
    );
  }

  // ── Show confirmation dialog — returns true if confirmed ──────────────────
  static Future<bool> confirm(
    BuildContext context, {
    required String message,
    String? title,
    String? yesLabel,
    String? noLabel,
  }) async {
    final s = AppL10n.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AppDialogWidget(
        type: DialogType.confirm,
        title: title ?? s.areYouSure,
        message: message,
        confirmLabel: yesLabel ?? s.yes,
        cancelLabel: noLabel ?? s.no,
      ),
    );
    return result ?? false;
  }

  // ── Show error from DioException or any exception ─────────────────────────
  static Future<void> showError(BuildContext context, dynamic error) {
    // Check for QUOTA_EXHAUSTED — show special dialog with redirect
    if (_isQuotaExhausted(error)) {
      return QuotaExhaustedDialog.show(context);
    }
    final message = _resolveErrorMessage(context, error);
    return show(context, type: DialogType.error, message: message);
  }

  static bool _isQuotaExhausted(dynamic error) {
    try {
      final data = (error as dynamic).response?.data;
      if (data is Map<String, dynamic>) {
        return data['errorCode'] == 'QUOTA_EXHAUSTED';
      }
    } catch (_) {}
    return false;
  }

  // ── Show success ──────────────────────────────────────────────────────────
  static Future<void> showSuccess(BuildContext context, String message) {
    return show(context, type: DialogType.success, message: message);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static String _defaultTitle(DialogType type, AppL10n s) => switch (type) {
        DialogType.success => s.dialogSuccess,
        DialogType.error => s.error,
        DialogType.warning => s.dialogWarning,
        DialogType.info => s.dialogInfo,
        DialogType.confirm => s.dialogConfirm,
      };

  static String _resolveErrorMessage(BuildContext context, dynamic error) {
    final s = AppL10n.of(context)!;
    try {
      // DioException check via duck typing (avoid hard import cycle)
      final response = (error as dynamic).response;
      final type = (error as dynamic).type?.toString() ?? '';

      if (type.contains('connectionTimeout') ||
          type.contains('receiveTimeout') ||
          type.contains('connectionError') ||
          type.contains('sendTimeout')) {
        return s.networkError;
      }

      final statusCode = response?.statusCode as int?;
      final data = response?.data;

      if (statusCode == 401) return s.sessionExpired;
      if (statusCode == 402) return s.insufficientCredits;

      if (data is Map<String, dynamic>) {
        // Try to translate via error code first
        final errorCode = data['errorCode'] as String?;
        final translated = ErrorCodeTranslator.translate(context, errorCode);
        if (translated != null) return translated;

        // For validation errors, join individual field messages
        if (data['errors'] is List) {
          final errors = data['errors'] as List;
          final messages = errors.map((e) {
            final code = (e as Map<String, dynamic>)['code'] as String?;
            final msg  = e['message'] as String?;
            return ErrorCodeTranslator.translate(context, code) ?? msg ?? code ?? '';
          }).where((m) => m.isNotEmpty).toList();
          if (messages.isNotEmpty) return messages.join('\n');
        }

        // Fallback to raw English message from backend
        if (data.containsKey('error')) return data['error'] as String;
      }

      return switch (statusCode) {
        400 => ErrorCodeTranslator.translate(context, 'VALIDATION_ERROR') ?? s.errorOccurred('Bad request'),
        403 => ErrorCodeTranslator.translate(context, 'FORBIDDEN')        ?? s.errorOccurred('Forbidden'),
        404 => ErrorCodeTranslator.translate(context, 'NOT_FOUND')        ?? s.errorOccurred('Not found'),
        500 => ErrorCodeTranslator.translate(context, 'INTERNAL_ERROR')   ?? s.errorOccurred('Server error'),
        _   => s.errorOccurred('Unknown error'),
      };
    } catch (_) {
      return s.errorOccurred(error.toString());
    }
  }
}

// ── Private dialog widget ──────────────────────────────────────────────────
class _AppDialogWidget extends StatelessWidget {
  final DialogType type;
  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;

  const _AppDialogWidget({
    required this.type,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _typeColors(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(_typeIcon, color: colors.fg, size: 32),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.fg,
                    ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 24),

              // Buttons
              if (cancelLabel != null)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(cancelLabel!,
                            style: TextStyle(color: Colors.grey[700])),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.fg,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(confirmLabel),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.fg,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _typeIcon => switch (type) {
        DialogType.success => Icons.check_circle_outline,
        DialogType.error => Icons.error_outline,
        DialogType.warning => Icons.warning_amber_outlined,
        DialogType.info => Icons.info_outline,
        DialogType.confirm => Icons.help_outline,
      };

  _TypeColors _typeColors(BuildContext context) => switch (type) {
        DialogType.success =>
          _TypeColors(bg: Colors.green.shade50, fg: Colors.green.shade700),
        DialogType.error =>
          _TypeColors(bg: Colors.red.shade50, fg: Colors.red.shade700),
        DialogType.warning =>
          _TypeColors(bg: Colors.orange.shade50, fg: Colors.orange.shade700),
        DialogType.info =>
          _TypeColors(bg: Colors.blue.shade50, fg: Colors.blue.shade700),
        DialogType.confirm =>
          _TypeColors(bg: Colors.indigo.shade50, fg: Colors.indigo.shade700),
      };
}

class _TypeColors {
  final Color bg;
  final Color fg;
  const _TypeColors({required this.bg, required this.fg});
}

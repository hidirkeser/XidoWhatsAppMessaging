import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';

class QuotaExhaustedDialog {
  static Future<void> show(BuildContext context) async {
    final s = AppL10n.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange[700]),
        title: Text(s.quotaExhausted),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.quotaExhaustedMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(s.upgradeYourPlan, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.later),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.upgrade),
            label: Text(s.viewPlans),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      context.push('/products');
    }
  }
}

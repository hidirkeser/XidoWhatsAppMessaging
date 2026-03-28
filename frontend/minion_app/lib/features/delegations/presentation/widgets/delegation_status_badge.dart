import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';

class DelegationStatusBadge extends StatelessWidget {
  final String status;

  const DelegationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    final (color, label) = switch (status.toLowerCase()) {
      'active' => (Colors.green, s.active),
      'pendingapproval' => (Colors.orange, s.pending),
      'rejected' => (Colors.red, s.rejected),
      'revoked' => (Colors.grey, s.revoked),
      'expired' => (Colors.grey.shade400, s.expired),
      _ => (Colors.grey, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

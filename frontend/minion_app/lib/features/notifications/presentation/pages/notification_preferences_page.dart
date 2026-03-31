import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../l10n/generated/app_localizations.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends State<NotificationPreferencesPage> {
  bool _loading = true;
  bool _saving = false;

  // Enabled flags (user can toggle)
  bool _inApp    = true;
  bool _push     = true;
  bool _email    = true;
  bool _whatsApp = false;
  bool _sms      = false;

  // Availability flags (from server config — read-only for the user)
  bool _inAppAvail    = true;
  bool _pushAvail     = false;
  bool _emailAvail    = false;
  bool _whatsAppAvail = false;
  bool _smsAvail      = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await sl<ApiClient>().dio.get(ApiEndpoints.notificationPreferences);
      final d = res.data as Map<String, dynamic>;
      setState(() {
        _inApp    = d['inAppEnabled']    as bool? ?? true;
        _push     = d['pushEnabled']     as bool? ?? true;
        _email    = d['emailEnabled']    as bool? ?? true;
        _whatsApp = d['whatsAppEnabled'] as bool? ?? false;
        _sms      = d['smsEnabled']      as bool? ?? false;

        _inAppAvail    = d['inAppAvailable']    as bool? ?? true;
        _pushAvail     = d['pushAvailable']     as bool? ?? false;
        _emailAvail    = d['emailAvailable']    as bool? ?? false;
        _whatsAppAvail = d['whatsAppAvailable'] as bool? ?? false;
        _smsAvail      = d['smsAvailable']      as bool? ?? false;

        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final s = AppL10n.of(context)!;
    setState(() => _saving = true);
    try {
      await sl<ApiClient>().dio.put(
        ApiEndpoints.notificationPreferences,
        data: {
          'inAppEnabled':    _inApp,
          'pushEnabled':     _push,
          'emailEnabled':    _email,
          'whatsAppEnabled': _whatsApp,
          'smsEnabled':      _sms,
        },
      );
      if (mounted) await AppDialog.showSuccess(context, s.notifSaveSuccess);
    } catch (e) {
      if (mounted) await AppDialog.showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s  = AppL10n.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.notifSettingsTitle),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  s.notifSettingsDesc,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 20),

                // In-App — always available, cannot be turned off completely
                _buildSection(
                  cs: cs,
                  title: s.notifChannelInApp,
                  subtitle: s.notifChannelInAppDesc,
                  icon: Icons.notifications_outlined,
                  value: _inApp,
                  available: _inAppAvail,
                  onChanged: (v) => setState(() => _inApp = v),
                ),

                // Push
                _buildSection(
                  cs: cs,
                  title: s.notifChannelPush,
                  subtitle: s.notifChannelPushDesc,
                  icon: Icons.phone_iphone_outlined,
                  value: _push,
                  available: _pushAvail,
                  onChanged: (v) => setState(() => _push = v),
                ),

                // Email
                _buildSection(
                  cs: cs,
                  title: s.notifChannelEmail,
                  subtitle: s.notifChannelEmailDesc,
                  icon: Icons.email_outlined,
                  value: _email,
                  available: _emailAvail,
                  onChanged: (v) => setState(() => _email = v),
                  note: _emailAvail ? s.notifRequiresEmail : null,
                ),

                // WhatsApp
                _buildSection(
                  cs: cs,
                  title: s.notifChannelWhatsApp,
                  subtitle: s.notifChannelWhatsAppDesc,
                  icon: Icons.chat_bubble_outline,
                  value: _whatsApp,
                  available: _whatsAppAvail,
                  onChanged: (v) => setState(() => _whatsApp = v),
                  note: _whatsAppAvail ? s.notifRequiresPhone : null,
                ),

                // SMS
                _buildSection(
                  cs: cs,
                  title: s.notifChannelSms,
                  subtitle: s.notifChannelSmsDesc,
                  icon: Icons.sms_outlined,
                  value: _sms,
                  available: _smsAvail,
                  onChanged: (v) => setState(() => _sms = v),
                  note: _smsAvail ? s.notifRequiresPhone : null,
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(s.save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required ColorScheme cs,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool available,
    required ValueChanged<bool> onChanged,
    String? note,
  }) {
    final s = AppL10n.of(context)!;

    // Inactive: channel not configured on the server
    final isInactive = !available;
    final effectiveValue = available && value;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isInactive
              ? cs.outlineVariant.withValues(alpha: 0.4)
              : cs.outlineVariant,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: isInactive ? 0.55 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isInactive
                          ? Colors.grey[100]
                          : (effectiveValue ? cs.primaryContainer : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20,
                        color: isInactive
                            ? Colors.grey[400]
                            : (effectiveValue ? cs.primary : Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: isInactive ? Colors.grey[500] : null,
                                ),
                              ),
                            ),
                            if (isInactive) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  s.notifChannelInactiveLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isInactive ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: effectiveValue,
                    onChanged: isInactive ? null : onChanged,
                  ),
                ],
              ),

              // Inactive explanation row
              if (isInactive) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          s.notifChannelInactiveDesc,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Active note (e.g. "requires email/phone in profile")
              if (!isInactive && note != null && effectiveValue) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: cs.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(note, style: TextStyle(fontSize: 12, color: cs.primary)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_dialog.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends State<NotificationPreferencesPage> {
  bool _loading = true;
  bool _saving = false;

  bool _inApp    = true;
  bool _push     = true;
  bool _email    = true;
  bool _whatsApp = false;
  bool _sms      = false;

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
        _loading  = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
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
      if (mounted) await AppDialog.showSuccess(context, 'Bildirim ayarları kaydedildi.');
    } catch (e) {
      if (mounted) await AppDialog.showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Bildirimleri hangi kanallardan almak istediğinizi seçin.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  cs: cs,
                  title: 'Uygulama İçi',
                  subtitle: 'Bildirimler uygulama içinde görünür',
                  icon: Icons.notifications_outlined,
                  value: _inApp,
                  onChanged: (v) => setState(() => _inApp = v),
                  isAlwaysOnHint: 'En az bir kanal aktif olmalıdır.',
                ),
                _buildSection(
                  cs: cs,
                  title: 'Push Bildirimi',
                  subtitle: 'Telefona anlık bildirim gönderilir',
                  icon: Icons.phone_iphone_outlined,
                  value: _push,
                  onChanged: (v) => setState(() => _push = v),
                ),
                _buildSection(
                  cs: cs,
                  title: 'E-posta',
                  subtitle: 'Profildeki e-posta adresinize gönderilir',
                  icon: Icons.email_outlined,
                  value: _email,
                  onChanged: (v) => setState(() => _email = v),
                  note: 'Profilde e-posta adresi tanımlı olmalıdır.',
                ),
                _buildSection(
                  cs: cs,
                  title: 'WhatsApp',
                  subtitle: 'Twilio üzerinden WhatsApp mesajı gönderilir',
                  icon: Icons.chat_bubble_outline,
                  value: _whatsApp,
                  onChanged: (v) => setState(() => _whatsApp = v),
                  note: 'Profilde telefon numarası tanımlı olmalıdır.',
                  badgeLabel: 'YAKINDA',
                ),
                _buildSection(
                  cs: cs,
                  title: 'SMS',
                  subtitle: 'Twilio üzerinden SMS gönderilir',
                  icon: Icons.sms_outlined,
                  value: _sms,
                  onChanged: (v) => setState(() => _sms = v),
                  note: 'Profilde telefon numarası tanımlı olmalıdır.',
                  badgeLabel: 'YAKINDA',
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
                        : const Text('Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
    required ValueChanged<bool> onChanged,
    String? note,
    String? badgeLabel,
    String? isAlwaysOnHint,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant),
      ),
      margin: const EdgeInsets.only(bottom: 12),
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
                    color: value ? cs.primaryContainer : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: value ? cs.primary : Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          if (badgeLabel != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(badgeLabel,
                                  style: TextStyle(fontSize: 10, color: Colors.orange[800], fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Switch(value: value, onChanged: onChanged),
              ],
            ),
            if (note != null && value) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.4),
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
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_dialog.dart';

/// WhatsApp mesaj formatı:
///   0 = ImageCard (SkiaSharp PNG kart — varsayılan)
///   1 = PlainText (düz metin)
enum WhatsAppCardFormat { imageCard, plainText }

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _loading = true;
  bool _saving  = false;
  WhatsAppCardFormat _format = WhatsAppCardFormat.imageCard;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await sl<ApiClient>().dio.get(ApiEndpoints.adminNotificationSettings);
      final v = (res.data['whatsAppCardFormat'] as int?) ?? 0;
      setState(() {
        _format  = v == 1 ? WhatsAppCardFormat.plainText : WhatsAppCardFormat.imageCard;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await sl<ApiClient>().dio.put(
        ApiEndpoints.adminNotificationSettings,
        data: {'whatsAppCardFormat': _format.index},
      );
      if (mounted) await AppDialog.showSuccess(context, 'Ayarlar kaydedildi.');
    } catch (e) {
      if (mounted) await AppDialog.showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bildirim Ayarları')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Başlık ───────────────────────────────────────────────
                Text(
                  'WhatsApp Mesaj Formatı',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Yetki talebi bildirimlerinde hangi format kullanılsın?',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 16),

                // ── Görsel Kart seçeneği ─────────────────────────────────
                _FormatCard(
                  selected: _format == WhatsAppCardFormat.imageCard,
                  icon: Icons.image_outlined,
                  title: 'Görsel Kart',
                  subtitle: 'Yetki bilgileri güzel tasarlanmış bir PNG kart olarak gönderilir.',
                  badge: 'Varsayılan',
                  badgeColor: cs.primary,
                  onTap: () => setState(() => _format = WhatsAppCardFormat.imageCard),
                ),
                const SizedBox(height: 10),

                // ── Düz Metin seçeneği ───────────────────────────────────
                _FormatCard(
                  selected: _format == WhatsAppCardFormat.plainText,
                  icon: Icons.text_snippet_outlined,
                  title: 'Düz Metin',
                  subtitle: 'Yetki bilgileri sade bir metin mesajı olarak gönderilir.',
                  onTap: () => setState(() => _format = WhatsAppCardFormat.plainText),
                ),

                const SizedBox(height: 32),

                // ── Önizleme ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.preview_outlined, size: 16, color: cs.primary),
                        const SizedBox(width: 6),
                        Text('Mesaj Önizlemesi',
                            style: TextStyle(fontWeight: FontWeight.w600, color: cs.primary)),
                      ]),
                      const SizedBox(height: 10),
                      if (_format == WhatsAppCardFormat.imageCard)
                        _PreviewImageCard()
                      else
                        _PreviewPlainText(),
                    ],
                  ),
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
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Kaydet',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Format seçim kartı ────────────────────────────────────────────────────────

class _FormatCard extends StatelessWidget {
  final bool     selected;
  final IconData icon;
  final String   title;
  final String   subtitle;
  final String?  badge;
  final Color?   badgeColor;
  final VoidCallback onTap;

  const _FormatCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer.withValues(alpha: 0.3) : cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? cs.primaryContainer : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: selected ? cs.primary : Colors.grey, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected ? cs.primary : null,
                        )),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (badgeColor ?? cs.primary).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(badge!,
                            style: TextStyle(
                              fontSize: 10,
                              color: badgeColor ?? cs.primary,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: selected,
              onChanged: (_) => onTap(),
              activeColor: cs.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Önizlemeler ───────────────────────────────────────────────────────────────

class _PreviewImageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text('⚡ Minion',
                style: TextStyle(color: Color(0xFFC5A028),
                    fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const Center(
            child: Text('Yeni Yetki Talebi',
                style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 11)),
          ),
          const Divider(color: Color(0xFFFFD700), height: 20),
          _row('Yetki Veren',   'BankID Test User'),
          _row('Yetki Verilen', 'HIDIR KESER'),
          _row('Kurum',         'Test Foretag AB'),
          _row('Yetkiler',      'Allmän representation'),
          _row('Geçerlilik',    '31.03.2026 – 30.04.2026'),
          const SizedBox(height: 8),
          const Center(
            child: Text('Kabul için Minion uygulamasını açın.',
                style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 10)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFC5A028),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('🌐  https://minion.se',
                  style: TextStyle(color: Color(0xFF1A1A2E),
                      fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 9,
                fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    ),
  );
}

class _PreviewPlainText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        '⚡ *Minion – Yeni Yetki Talebi*\n\n'
        'Merhaba *HIDIR KESER*,\n\n'
        '*BankID Test User* sizi *Test Foretag AB* kurumunda yetkilendirmek istiyor.\n\n'
        '📋 *İşlemler:* Allmän representation\n'
        '📅 *Geçerlilik:* 31.03.2026 – 30.04.2026\n\n'
        '👉 Kabul veya reddetmek için Minion uygulamasını açın.\n\n'
        '🌐 https://minion.se',
        style: TextStyle(fontSize: 12, color: Color(0xFF1A1A1A), height: 1.5),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';

class VerificationPage extends StatefulWidget {
  final String code;
  const VerificationPage({super.key, required this.code});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await sl<ApiClient>().dio.get(
        '${ApiEndpoints.baseUrl.replaceAll('/api', '')}/api/verify/${widget.code}',
      );
      setState(() {
        _data = res.data as Map<String, dynamic>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Yetki bulunamadı veya geçersiz kod.';
        _loading = false;
      });
    }
  }

  /// True if delegation is Active AND current time is within [validFrom, validTo]
  bool _isCurrentlyValid(Map<String, dynamic> d) {
    final status = (d['status'] as String? ?? '').toLowerCase();
    if (status != 'active') return false;
    final from = DateTime.tryParse(d['validFrom'] as String? ?? '');
    final to   = DateTime.tryParse(d['validTo']   as String? ?? '');
    if (from == null || to == null) return false;
    final now = DateTime.now().toUtc();
    return now.isAfter(from) && now.isBefore(to);
  }

  bool _isPeriodExpired(Map<String, dynamic> d) {
    final to = DateTime.tryParse(d['validTo'] as String? ?? '');
    if (to == null) return false;
    return DateTime.now().toUtc().isAfter(to);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo ──────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 36, color: cs.primary),
                    const SizedBox(width: 10),
                    Text('Minion',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                            letterSpacing: -0.5)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Yetki Doğrulama',
                    style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
                const SizedBox(height: 32),

                if (_loading)
                  const CircularProgressIndicator()
                else if (_error != null)
                  _buildError(cs)
                else
                  _buildResult(cs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(ColorScheme cs) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 56, color: cs.error),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: cs.error)),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(ColorScheme cs) {
    final d = _data!;
    final isValid   = _isCurrentlyValid(d);
    final isExpired = _isPeriodExpired(d);
    final status    = (d['status'] as String? ?? '').toLowerCase();

    // Determine banner appearance
    final Color bannerColor;
    final IconData bannerIcon;
    final String bannerLabel;
    final String bannerSub;

    if (_confirmed) {
      bannerColor = Colors.green;
      bannerIcon  = Icons.check_circle;
      bannerLabel = 'YETKİ ONAYLANDI';
      bannerSub   = 'Bu yetki geçerli olduğu doğrulandı.';
    } else if (isValid) {
      bannerColor = Colors.green;
      bannerIcon  = Icons.verified_user;
      bannerLabel = 'YETKİ GEÇERLİ';
      bannerSub   = 'Bu yetki şu anda aktif ve geçerlilik süresi içinde.';
    } else if (isExpired || status == 'expired') {
      bannerColor = Colors.red;
      bannerIcon  = Icons.timer_off_outlined;
      bannerLabel = 'SÜRESİ DOLMUŞ';
      bannerSub   = 'Bu yetkinin geçerlilik süresi sona ermiştir.';
    } else if (status == 'revoked') {
      bannerColor = Colors.red;
      bannerIcon  = Icons.block;
      bannerLabel = 'İPTAL EDİLDİ';
      bannerSub   = 'Bu yetki iptal edilmiştir.';
    } else if (status == 'rejected') {
      bannerColor = Colors.red;
      bannerIcon  = Icons.cancel_outlined;
      bannerLabel = 'REDDEDİLDİ';
      bannerSub   = 'Bu yetki reddedilmiştir.';
    } else if (status == 'pendingapproval') {
      bannerColor = Colors.orange;
      bannerIcon  = Icons.hourglass_empty;
      bannerLabel = 'ONAY BEKLİYOR';
      bannerSub   = 'Bu yetki henüz onaylanmamıştır.';
    } else {
      bannerColor = Colors.grey;
      bannerIcon  = Icons.info_outline;
      bannerLabel = status.toUpperCase();
      bannerSub   = '';
    }

    return Column(
      children: [
        // ── Status banner ────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: bannerColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bannerColor.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(bannerIcon, color: bannerColor, size: 32),
                  const SizedBox(width: 12),
                  Text(bannerLabel,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: bannerColor)),
                ],
              ),
              if (bannerSub.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(bannerSub,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: bannerColor.withValues(alpha: 0.8))),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Details card ─────────────────────────────────────────────────
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _row(Icons.person, 'Yetki Veren', d['grantorName'] ?? '-'),
                const Divider(height: 20),
                _row(Icons.person_outline, 'Yetkili Kişi', d['delegateName'] ?? '-'),
                const Divider(height: 20),
                _row(Icons.business, 'Kurum', d['organizationName'] ?? '-'),
                const Divider(height: 20),
                _row(Icons.calendar_today, 'Geçerlilik',
                    '${_fmtDateTime(d['validFrom'])} – ${_fmtDateTime(d['validTo'])}'),
                if ((d['operations'] as List?)?.isNotEmpty == true) ...[
                  const Divider(height: 20),
                  _operationsRow(d['operations'] as List),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Confirm button (only if currently valid and not yet confirmed) ─
        if (isValid && !_confirmed)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _confirmed = true),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Yetkiyi Onayla',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

        // ── Expired message ───────────────────────────────────────────────
        if (!isValid && isExpired)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.red, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bu yetkinin geçerlilik süresi dolmuştur. Yetki veren ile iletişime geçin.',
                    style: TextStyle(fontSize: 13, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // ── Verification code ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tag, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(widget.code,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Footer ────────────────────────────────────────────────────────
        Text('Minion — Dijital Yetki Yönetim Platformu',
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _operationsRow(List ops) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.assignment_outlined, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('İşlem Türleri',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ops.map((op) => Chip(
                  label: Text(op['operationName'] ?? '',
                      style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _fmtDateTime(String? s) {
    if (s == null) return '-';
    final d = DateTime.tryParse(s);
    if (d == null) return '-';
    final local = d.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

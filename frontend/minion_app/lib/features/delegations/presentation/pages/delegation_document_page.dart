import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/bankid_sign_sheet.dart';

/// Delegation için Vekaletname (Fullmakt / Power of Attorney) sayfası.
///
/// Akış:
///   1. Belge yok → "Oluştur" butonu → generate endpoint → sayfayı yenile
///   2. PendingGrantorApproval  → Asil BankID ile imzalar
///   3. PendingDelegateApproval → Vekil BankID ile imzalar
///   4. FullyApproved → PDF indir + QR doğrulama göster
///   5. Rejected → durum mesajı
class DelegationDocumentPage extends StatefulWidget {
  final String delegationId;

  const DelegationDocumentPage({super.key, required this.delegationId});

  @override
  State<DelegationDocumentPage> createState() => _DelegationDocumentPageState();
}

class _DelegationDocumentPageState extends State<DelegationDocumentPage> {
  Map<String, dynamic>? _doc;
  Map<String, dynamic>? _delegation;
  bool _loading = true;
  bool _generating = false;
  bool _signing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Load delegation info
      final delRes = await sl<ApiClient>().dio.get(
          ApiEndpoints.delegationById(widget.delegationId));
      _delegation = delRes.data as Map<String, dynamic>;

      // Load document (may 404 if not yet generated)
      try {
        final docRes = await sl<ApiClient>().dio.get(
            ApiEndpoints.delegationDocument(widget.delegationId));
        _doc = docRes.data as Map<String, dynamic>;
      } catch (_) {
        _doc = null; // No document yet
      }
    } catch (e) {
      _error = 'Yüklenemedi.';
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      final res = await sl<ApiClient>().dio.post(
        ApiEndpoints.delegationDocumentGenerate(widget.delegationId),
        data: {'language': 'en'},
      );
      setState(() => _doc = res.data as Map<String, dynamic>);
    } catch (e) {
      if (mounted) await AppDialog.showError(context, e);
    } finally {
      setState(() => _generating = false);
    }
  }

  Future<void> _sign(String action) async {
    final d = _delegation!;
    final signText = action == 'grantor'
        ? 'Minion - Fullmakt / Power of Attorney\n\nJag, ${d['grantorName']}, godkänner denna fullmakt att ${d['delegateName']} representerar ${d['organizationName']}.'
        : 'Minion - Fullmakt / Power of Attorney\n\nJag, ${d['delegateName']}, accepterar denna fullmakt från ${d['grantorName']} för ${d['organizationName']}.';

    await BankIdSignSheet.show(
      context,
      userVisibleText: signText,
      onComplete: (orderRef, signature) async {
        setState(() => _signing = true);
        try {
          final res = await sl<ApiClient>().dio.post(
            ApiEndpoints.delegationDocumentApprove(widget.delegationId),
            data: {'bankIdSignature': signature},
          );
          setState(() => _doc = res.data as Map<String, dynamic>);
          if (mounted) await AppDialog.showSuccess(context, 'Belge imzalandı.');
        } catch (e) {
          if (mounted) await AppDialog.showError(context, e);
        } finally {
          setState(() => _signing = false);
        }
      },
    );
  }

  Future<void> _downloadPdf(String verificationCode) async {
    final url = '${sl<ApiClient>().dio.options.baseUrl.replaceAll('/api', '')}/api${ApiEndpoints.publicDocumentPdf(verificationCode)}';
    if (kIsWeb) {
      // On web, open in new tab
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF URL kopyalandı — tarayıcıda açın.')));
    } else {
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF bağlantısı kopyalandı.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vekaletname'),
        actions: [
          if (!_loading)
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_doc == null) {
      return _buildNoDocument(context, cs);
    }

    final status = (_doc!['status'] as String? ?? '').toLowerCase();
    final verificationCode = _doc!['verificationCode'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBanner(status, cs),
          const SizedBox(height: 20),
          _buildPartiesCard(context),
          const SizedBox(height: 16),
          _buildSignaturesCard(context, status),

          // ── Actions based on status ──────────────────────────────
          const SizedBox(height: 24),
          if (status == 'pendinggrantorapproval')
            _buildSignButton(context, 'grantor', 'Asil Olarak İmzala (BankID)'),
          if (status == 'pendingdelegateapproval')
            _buildSignButton(context, 'delegate', 'Vekil Olarak İmzala (BankID)'),

          // ── Fully approved: QR + PDF ────────────────────────────
          if (status == 'fullyapproved' && verificationCode != null) ...[
            _buildQrSection(context, verificationCode),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _downloadPdf(verificationCode),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF İndir'),
              ),
            ),
          ],

          if (status == 'rejected') ...[
            const SizedBox(height: 8),
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reddedildi', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
                    if (_doc!['rejectionReason'] != null) ...[
                      const SizedBox(height: 6),
                      Text(_doc!['rejectionReason']),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoDocument(BuildContext context, ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 72, color: cs.outline),
            const SizedBox(height: 16),
            Text('Henüz bir vekaletname belgesi oluşturulmadı.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Belge oluşturulduktan sonra her iki taraf BankID ile imzalamalıdır.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _generating ? null : _generate,
                icon: _generating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add_circle_outline),
                label: const Text('Vekaletname Oluştur', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(String status, ColorScheme cs) {
    final (color, icon, title) = switch (status) {
      'fullyapproved'           => (Colors.green, Icons.verified, 'TAM ONAYLANDI'),
      'pendinggrantorapproval'  => (Colors.orange, Icons.draw_outlined, 'ASİL İMZASI BEKLENİYOR'),
      'pendingdelegateapproval' => (Colors.blue, Icons.draw_outlined, 'VEKİL İMZASI BEKLENİYOR'),
      'rejected'                => (Colors.red, Icons.cancel, 'REDDEDİLDİ'),
      _                         => (Colors.grey, Icons.hourglass_empty, status.toUpperCase()),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 15)),
      ]),
    );
  }

  Widget _buildPartiesCard(BuildContext context) {
    final d = _delegation!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _infoRow(Icons.person, 'Asil (Yetki Veren)', d['grantorName'] ?? '-'),
          const Divider(height: 20),
          _infoRow(Icons.person_outline, 'Vekil (Yetkili)', d['delegateName'] ?? '-'),
          const Divider(height: 20),
          _infoRow(Icons.business, 'Kurum', d['organizationName'] ?? '-'),
        ]),
      ),
    );
  }

  Widget _buildSignaturesCard(BuildContext context, String status) {
    final doc = _doc!;
    final grantorSigned = doc['grantorApprovedAt'] != null;
    final delegateSigned = doc['delegateApprovedAt'] != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('İmzalar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            _signatureRow('Asil İmzası', grantorSigned, doc['grantorApprovedAt']),
            const SizedBox(height: 8),
            _signatureRow('Vekil İmzası', delegateSigned, doc['delegateApprovedAt']),
          ],
        ),
      ),
    );
  }

  Widget _signatureRow(String label, bool signed, dynamic timestamp) {
    return Row(children: [
      Icon(signed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: signed ? Colors.green : Colors.grey, size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          if (signed && timestamp != null)
            Text(_formatDate(timestamp.toString()),
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ]),
      ),
    ]);
  }

  Widget _buildSignButton(BuildContext context, String role, String label) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: _signing ? null : () => _sign(role),
        icon: _signing
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.fingerprint),
        label: Text(label, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _buildQrSection(BuildContext context, String verificationCode) {
    final websiteBase = kReleaseMode
        ? 'https://minion.se'
        : 'http://localhost:8080';
    final qrUrl = '$websiteBase/verify/$verificationCode';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('QR Doğrulama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Üçüncü taraflar bu kodu tarayarak belgeyi doğrulayabilir',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: QrImageView(
                data: qrUrl,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: verificationCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kod kopyalandı')));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(verificationCode,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 18,
                          fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(width: 8),
                  const Icon(Icons.copy, size: 18),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: Colors.grey, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      )),
    ]);
  }

  String _formatDate(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return '${dt.day}.${dt.month}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

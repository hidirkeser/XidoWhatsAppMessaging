import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

class CorporateApplicationStatusPage extends StatefulWidget {
  final String applicationId;
  const CorporateApplicationStatusPage({super.key, required this.applicationId});

  @override
  State<CorporateApplicationStatusPage> createState() => _CorporateApplicationStatusPageState();
}

class _CorporateApplicationStatusPageState extends State<CorporateApplicationStatusPage> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  // Resubmit state
  final Map<String, PlatformFile?> _newDocs = {
    'RegistrationCertificate': null,
    'SignatoryDocument': null,
    'IdentityDocument': null,
  };
  bool _resubmitting = false;

  static const _docLabels = {
    'RegistrationCertificate': 'Registreringsbevis / Ticaret Sicil',
    'SignatoryDocument':       'Firmatecknare / İmza Sirküleri',
    'IdentityDocument':        'Kimlik Belgesi',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await sl<ApiClient>().dio.get(
          ApiEndpoints.corporateApplicationById(widget.applicationId));
      setState(() { _data = res.data as Map<String, dynamic>; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDoc(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _newDocs[type] = result.files.first);
    }
  }

  Future<void> _resubmit() async {
    setState(() => _resubmitting = true);
    try {
      final docsJson = <Map<String, dynamic>>[];
      for (final entry in _newDocs.entries) {
        final file = entry.value;
        if (file == null) continue;
        docsJson.add({
          'type': entry.key,
          'name': file.name,
          'uploadedAt': DateTime.now().toIso8601String(),
        });
      }

      await sl<ApiClient>().dio.post(
        ApiEndpoints.corporateApplicationResubmit(widget.applicationId),
        data: {'documentsJson': jsonEncode(docsJson)},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Başvuru yeniden gönderildi.')));
        _load(); // refresh
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hata oluştu.')));
    } finally {
      setState(() => _resubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_data == null) return const Scaffold(body: Center(child: Text('Başvuru bulunamadı.')));

    final status      = _data!['status'] as String? ?? '';
    final reviewNote  = _data!['reviewNote'] as String?;
    final resubmitCount = _data!['resubmitCount'] as int? ?? 0;

    final (color, icon, title) = switch (status.toLowerCase()) {
      'approved'         => (Colors.green, Icons.check_circle, 'ONAYLANDI'),
      'rejected'         => (Colors.red,   Icons.cancel,       'REDDEDİLDİ'),
      'documentsrequired'=> (Colors.orange, Icons.folder_open, 'EKSİK EVRAK'),
      _                  => (Colors.blue,  Icons.hourglass_empty, 'İNCELENİYOR'),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Başvuru Durumu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(width: 12),
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Company info card
            Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _infoRow('Şirket', _data!['companyName'] ?? '-'),
                const Divider(height: 16),
                _infoRow('Sicil No', _data!['orgNumber'] ?? '-'),
                const Divider(height: 16),
                _infoRow('İletişim', _data!['contactName'] ?? '-'),
                const Divider(height: 16),
                _infoRow('Yeniden Gönderim', '$resubmitCount / 3'),
              ]),
            )),
            const SizedBox(height: 16),

            // Admin review note
            if (reviewNote != null && reviewNote.isNotEmpty)
              Card(
                color: (status.toLowerCase() == 'documentsrequired' ? Colors.orange : Colors.red).withOpacity(0.08),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.comment_outlined, size: 16, color: cs.onSurface),
                      const SizedBox(width: 6),
                      Text('Admin Notu', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                    ]),
                    const SizedBox(height: 6),
                    Text(reviewNote, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),

            // Resubmit section
            if (status.toLowerCase() == 'documentsrequired' && resubmitCount < 3) ...[
              const SizedBox(height: 24),
              Text('Belgeleri Güncelle',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Eksik veya hatalı belgeleri değiştirip yeniden gönderin.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 16),
              ..._newDocs.keys.map((type) => _buildDocRow(type)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _resubmitting ? null : _resubmit,
                  icon: _resubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send),
                  label: const Text('Yeniden Gönder'),
                ),
              ),
            ],

            if (status.toLowerCase() == 'approved') ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home),
                  label: const Text('Uygulamaya Git'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    ],
  );

  Widget _buildDocRow(String type) {
    final file  = _newDocs[type];
    final label = _docLabels[type]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: file != null ? Colors.green : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(file != null ? Icons.check_circle : Icons.upload_file, size: 18,
                color: file != null ? Colors.green : Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(file != null ? file.name : label,
                style: TextStyle(fontSize: 13, color: file != null ? Colors.green[700] : null),
                overflow: TextOverflow.ellipsis)),
          ]),
        )),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () => _pickDoc(type),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
          child: Text(file != null ? 'Değiştir' : 'Seç'),
        ),
      ]),
    );
  }
}

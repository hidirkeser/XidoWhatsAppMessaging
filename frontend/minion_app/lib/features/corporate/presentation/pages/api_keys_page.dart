import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/widgets/app_dialog.dart';

class ApiKeysPage extends StatefulWidget {
  final String orgId;
  const ApiKeysPage({super.key, required this.orgId});

  @override
  State<ApiKeysPage> createState() => _ApiKeysPageState();
}

class _ApiKeysPageState extends State<ApiKeysPage> {
  List<dynamic> _keys = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await sl<ApiClient>().dio.get(ApiEndpoints.orgApiKeys(widget.orgId));
      setState(() => _keys = res.data as List);
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _createKey() async {
    final nameC = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni API Anahtarı'),
        content: TextField(
          controller: nameC,
          decoration: const InputDecoration(
            labelText: 'Anahtar Adı (ör: ERP Entegrasyonu)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Oluştur')),
        ],
      ),
    );

    if (confirmed != true || nameC.text.trim().isEmpty) return;

    try {
      final res = await sl<ApiClient>().dio.post(
        ApiEndpoints.orgApiKeys(widget.orgId),
        data: {'name': nameC.text.trim()},
      );
      if (!mounted) return;
      await _showKeyCreatedDialog(res.data);
      _load();
    } catch (e) {
      if (mounted) await AppDialog.showError(context, e);
    }
  }

  Future<void> _showKeyCreatedDialog(Map<String, dynamic> data) async {
    final keyId  = data['keyId'] as String;
    final secret = data['secret'] as String;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.key, color: Colors.orange),
          SizedBox(width: 8),
          Text('Anahtar Oluşturuldu'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ Secret bir daha gösterilmeyecek. Hemen kopyalayın.',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _credentialTile('Key ID', keyId),
            const SizedBox(height: 8),
            _credentialTile('Secret', secret),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Key ID: $keyId\nSecret: $secret'));
              Navigator.pop(ctx);
            },
            child: const Text('Kopyala ve Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _credentialTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: SelectableText(
            value,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _revoke(String id, String name) async {
    final confirmed = await AppDialog.confirm(context,
        message: '"$name" anahtarını iptal etmek istediğinize emin misiniz?');
    if (!confirmed) return;

    try {
      await sl<ApiClient>().dio.delete(ApiEndpoints.orgApiKeyById(widget.orgId, id));
      _load();
    } catch (e) {
      if (mounted) await AppDialog.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Erişimi'),
        actions: [
          IconButton(onPressed: _createKey, icon: const Icon(Icons.add), tooltip: 'Yeni Anahtar'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _keys.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _keys.length,
                    itemBuilder: (_, i) => _buildKeyCard(_keys[i]),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.vpn_key_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Henüz API anahtarı oluşturulmamış.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _createKey,
            icon: const Icon(Icons.add),
            label: const Text('Anahtar Oluştur'),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyCard(Map<String, dynamic> key) {
    final isActive   = key['isActive'] as bool? ?? false;
    final name       = key['name'] as String? ?? '-';
    final keyId      = key['keyId'] as String? ?? '-';
    final lastUsed   = key['lastUsedAt'] as String?;
    final reqCount   = key['requestCount'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isActive ? Icons.key : Icons.key_off,
                    color: isActive ? Colors.green : Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600))),
                if (isActive)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _revoke(key['id'] as String, name),
                    tooltip: 'İptal Et',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Key ID: $keyId',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.bar_chart, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('$reqCount istek', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(width: 16),
              if (lastUsed != null) ...[
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(_fmtDate(lastUsed), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ]),
            if (!isActive) ...[
              const SizedBox(height: 6),
              const Text('İPTAL EDİLDİ', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtDate(String s) {
    final d = DateTime.tryParse(s);
    if (d == null) return '-';
    final l = d.toLocal();
    return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')}.${l.year}';
  }
}

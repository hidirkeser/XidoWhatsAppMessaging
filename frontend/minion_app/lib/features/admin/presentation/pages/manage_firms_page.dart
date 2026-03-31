import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

class ManageFirmsPage extends StatefulWidget {
  const ManageFirmsPage({super.key});

  @override
  State<ManageFirmsPage> createState() => _ManageFirmsPageState();
}

class _ManageFirmsPageState extends State<ManageFirmsPage> {
  List<dynamic> _orgs = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _searchC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchC.addListener(_filter);
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await sl<ApiClient>().dio.get(ApiEndpoints.organizations);
      final list = res.data as List? ?? [];
      setState(() { _orgs = list; _filtered = list; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _searchC.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _orgs
          : _orgs.where((o) =>
              (o['name'] as String? ?? '').toLowerCase().contains(q) ||
              (o['orgNumber'] as String? ?? '').toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Firma İşlemleri')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchC,
              decoration: InputDecoration(
                hintText: 'Firma adı veya sicil no ile ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
                suffixIcon: _searchC.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () { _searchC.clear(); _filter(); },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text('Firma bulunamadı', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemBuilder: (_, i) => _buildOrgCard(_filtered[i], theme),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrgCard(dynamic org, ThemeData theme) {
    final isActive = org['isActive'] as bool? ?? false;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isActive ? Colors.green : Colors.grey).withOpacity(0.1),
          child: Icon(
            Icons.business,
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(org['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${org['orgNumber'] ?? ''}'
          '${org['city'] != null ? ' • ${org['city']}' : ''}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Text('Pasif', style: TextStyle(fontSize: 11, color: Colors.orange)),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context.push('/admin/firms/${org['id']}'),
      ),
    );
  }
}

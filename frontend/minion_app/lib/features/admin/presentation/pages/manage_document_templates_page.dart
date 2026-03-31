import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ManageDocumentTemplatesPage extends StatefulWidget {
  const ManageDocumentTemplatesPage({super.key});

  @override
  State<ManageDocumentTemplatesPage> createState() => _ManageDocumentTemplatesPageState();
}

class _ManageDocumentTemplatesPageState extends State<ManageDocumentTemplatesPage> {
  List<dynamic> _templates = [];
  bool _loading = true;
  String? _filterLanguage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final query = _filterLanguage != null ? '?language=$_filterLanguage' : '';
      final res = await sl<ApiClient>().dio.get('/admin/document-templates$query');
      setState(() {
        _templates = res.data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggle(String id) async {
    try {
      await sl<ApiClient>().dio.put('/admin/document-templates/$id/toggle');
      _load();
    } catch (e) {
      if (mounted) await AppDialog.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.documentTemplates),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/document-templates/new').then((_) => _load()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Language filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: s.all, selected: _filterLanguage == null,
                    onTap: () { setState(() => _filterLanguage = null); _load(); }),
                  const SizedBox(width: 8),
                  for (final lang in ['en', 'sv', 'tr', 'de', 'es', 'fr'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: lang.toUpperCase(),
                        selected: _filterLanguage == lang,
                        onTap: () { setState(() => _filterLanguage = lang); _load(); },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Templates list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _templates.isEmpty
                    ? Center(child: Text(s.noDataFound, style: TextStyle(color: Colors.grey[600])))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _templates.length,
                          itemBuilder: (context, index) {
                            final t = _templates[index];
                            final isActive = t['isActive'] as bool;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isActive
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : Colors.grey.withValues(alpha: 0.15),
                                  child: Text(
                                    (t['language'] as String).toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isActive ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${t['languageName']} — v${t['version']}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  isActive ? s.active : s.inactive,
                                  style: TextStyle(
                                    color: isActive ? Colors.green : Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Switch(
                                      value: isActive,
                                      onChanged: (_) => _toggle(t['id']),
                                      activeColor: cs.primary,
                                    ),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                                onTap: () => context.push('/admin/document-templates/${t['id']}').then((_) => _load()),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? cs.onPrimary : cs.onSurface,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

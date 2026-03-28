import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ManageOrganizationsPage extends StatefulWidget {
  const ManageOrganizationsPage({super.key});

  @override
  State<ManageOrganizationsPage> createState() => _ManageOrganizationsPageState();
}

class _ManageOrganizationsPageState extends State<ManageOrganizationsPage> {
  List<dynamic> _orgs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await sl<ApiClient>().dio.get('/organizations');
      setState(() { _orgs = response.data as List; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _orgs.length,
                itemBuilder: (context, i) {
                  final org = _orgs[i];
                  final s = AppL10n.of(context)!;
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.business)),
                      title: Text(org['name'] ?? ''),
                      subtitle: Text('${s.orgNumber}: ${org['orgNumber'] ?? ''} | ${org['city'] ?? ''}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showEditDialog(org)),
                          IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _delete(org['id'])),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _showCreateDialog() async {
    final s = AppL10n.of(context)!;
    final nameC = TextEditingController();
    final orgNumC = TextEditingController();
    final cityC = TextEditingController();

    final result = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(s.newOrganization),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, decoration: InputDecoration(labelText: s.orgName)),
        TextField(controller: orgNumC, decoration: InputDecoration(labelText: s.orgNumber)),
        TextField(controller: cityC, decoration: InputDecoration(labelText: s.city)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.create)),
      ],
    ));

    if (result == true && nameC.text.isNotEmpty) {
      await sl<ApiClient>().dio.post('/organizations', data: {
        'name': nameC.text, 'orgNumber': orgNumC.text, 'city': cityC.text,
      });
      _load();
    }
  }

  Future<void> _showEditDialog(dynamic org) async {
    final s = AppL10n.of(context)!;
    final nameC = TextEditingController(text: org['name']);
    final cityC = TextEditingController(text: org['city'] ?? '');

    final result = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(s.editOrganization),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, decoration: InputDecoration(labelText: s.orgName)),
        TextField(controller: cityC, decoration: InputDecoration(labelText: s.city)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.save)),
      ],
    ));

    if (result == true) {
      await sl<ApiClient>().dio.put('/organizations/${org['id']}', data: {
        'name': nameC.text, 'city': cityC.text,
      });
      _load();
    }
  }

  Future<void> _delete(String id) async {
    final s = AppL10n.of(context)!;
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(s.deleteOrganization),
      content: Text(s.deleteOrgConfirm),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(s.delete),
        ),
      ],
    ));

    if (confirm == true) {
      await sl<ApiClient>().dio.delete('/organizations/$id');
      _load();
    }
  }
}

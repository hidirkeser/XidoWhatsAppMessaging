import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ManageCreditPackagesPage extends StatefulWidget {
  const ManageCreditPackagesPage({super.key});

  @override
  State<ManageCreditPackagesPage> createState() => _ManageCreditPackagesPageState();
}

class _ManageCreditPackagesPageState extends State<ManageCreditPackagesPage> {
  List<dynamic> _packages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await sl<ApiClient>().dio.get('/admin/credit-packages');
      setState(() { _packages = response.data as List; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _packages.length,
                itemBuilder: (context, i) {
                  final p = _packages[i];
                  final isActive = p['isActive'] as bool? ?? true;
                  return Card(
                    color: isActive ? null : Colors.grey[100],
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isActive ? Colors.green[50] : Colors.grey[200],
                        child: Text('${p['creditAmount']}',
                            style: TextStyle(fontWeight: FontWeight.bold,
                                color: isActive ? Colors.green : Colors.grey)),
                      ),
                      title: Text(p['name'] ?? '', style: TextStyle(
                          decoration: isActive ? null : TextDecoration.lineThrough)),
                      subtitle: Builder(builder: (ctx) {
                        final s = AppL10n.of(ctx)!;
                        return Text('${p['priceSEK']} SEK | ${p['creditAmount']} ${s.credits}');
                      }),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: isActive,
                            onChanged: (_) => _toggle(p['id']),
                          ),
                          IconButton(icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showEditDialog(p)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _toggle(String id) async {
    await sl<ApiClient>().dio.patch('/admin/credit-packages/$id/toggle');
    _load();
  }

  Future<void> _showCreateDialog() async {
    final s = AppL10n.of(context)!;
    final nameC = TextEditingController();
    final amountC = TextEditingController();
    final priceC = TextEditingController();
    final descC = TextEditingController();

    final result = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(s.newPackage),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, decoration: InputDecoration(labelText: s.packageName)),
        TextField(controller: amountC, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: s.creditAmount)),
        TextField(controller: priceC, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: s.priceSEK)),
        TextField(controller: descC, decoration: InputDecoration(labelText: s.description)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.create)),
      ],
    ));

    if (result == true && nameC.text.isNotEmpty) {
      await sl<ApiClient>().dio.post('/admin/credit-packages', data: {
        'name': nameC.text,
        'creditAmount': int.tryParse(amountC.text) ?? 0,
        'priceSEK': double.tryParse(priceC.text) ?? 0,
        'description': descC.text,
      });
      _load();
    }
  }

  Future<void> _showEditDialog(dynamic p) async {
    final s = AppL10n.of(context)!;
    final nameC = TextEditingController(text: p['name']);
    final amountC = TextEditingController(text: '${p['creditAmount']}');
    final priceC = TextEditingController(text: '${p['priceSEK']}');

    final result = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(s.editPackage),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, decoration: InputDecoration(labelText: s.packageName)),
        TextField(controller: amountC, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: s.creditAmount)),
        TextField(controller: priceC, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: s.priceSEK)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.save)),
      ],
    ));

    if (result == true) {
      await sl<ApiClient>().dio.put('/admin/credit-packages/${p['id']}', data: {
        'name': nameC.text,
        'creditAmount': int.tryParse(amountC.text),
        'priceSEK': double.tryParse(priceC.text),
      });
      _load();
    }
  }
}

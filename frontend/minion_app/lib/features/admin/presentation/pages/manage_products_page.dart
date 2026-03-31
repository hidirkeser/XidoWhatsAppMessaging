import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  List<dynamic> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await sl<ApiClient>().dio.get(ApiEndpoints.adminProducts);
      setState(() { _products = response.data as List; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
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
                itemCount: _products.length,
                itemBuilder: (context, i) {
                  final p = _products[i];
                  final isActive = p['isActive'] as bool? ?? true;
                  final type = p['type'] ?? '';
                  return Card(
                    color: isActive ? null : Colors.grey[100],
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: type == 'Corporate' ? Colors.blue[50] : Colors.green[50],
                        child: Icon(
                          type == 'Corporate' ? Icons.business : Icons.person,
                          color: type == 'Corporate' ? Colors.blue : Colors.green,
                        ),
                      ),
                      title: Text(p['name'] ?? '', style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: isActive ? null : TextDecoration.lineThrough,
                      )),
                      subtitle: Text('${p['priceSEK']} SEK | ${p['monthlyQuota']} ${s.operationsPerMonth} | $type'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(value: isActive, onChanged: (_) => _toggle(p['id'])),
                          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showEditDialog(p)),
                          IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _delete(p['id'])),
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
    await sl<ApiClient>().dio.patch(ApiEndpoints.adminProductToggle(id));
    _load();
  }

  Future<void> _delete(String id) async {
    final s = AppL10n.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.confirmDelete),
        content: Text(s.confirmDeleteProduct),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await sl<ApiClient>().dio.delete(ApiEndpoints.adminProductById(id));
      _load();
    }
  }

  Future<void> _showCreateDialog() async {
    final s = AppL10n.of(context)!;
    final nameC = TextEditingController();
    final descC = TextEditingController();
    final quotaC = TextEditingController();
    final priceC = TextEditingController();
    String selectedType = 'Individual';

    final result = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text(s.newProduct),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameC, decoration: InputDecoration(labelText: s.productName)),
          TextField(controller: descC, decoration: InputDecoration(labelText: s.description)),
          TextField(controller: quotaC, keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: s.monthlyQuota)),
          TextField(controller: priceC, keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: s.priceSEK)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: InputDecoration(labelText: s.productType),
            items: ['Individual', 'Corporate'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setDialogState(() => selectedType = v!),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.create)),
        ],
      ),
    ));

    if (result == true && nameC.text.isNotEmpty) {
      await sl<ApiClient>().dio.post(ApiEndpoints.adminProducts, data: {
        'name': nameC.text,
        'description': descC.text,
        'type': selectedType,
        'monthlyQuota': int.tryParse(quotaC.text) ?? 0,
        'priceSEK': double.tryParse(priceC.text) ?? 0,
      });
      _load();
    }
  }

  Future<void> _showEditDialog(dynamic p) async {
    final s = AppL10n.of(context)!;
    final nameC = TextEditingController(text: p['name']);
    final descC = TextEditingController(text: p['description'] ?? '');
    final quotaC = TextEditingController(text: '${p['monthlyQuota']}');
    final priceC = TextEditingController(text: '${p['priceSEK']}');

    final result = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(s.editProduct),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, decoration: InputDecoration(labelText: s.productName)),
        TextField(controller: descC, decoration: InputDecoration(labelText: s.description)),
        TextField(controller: quotaC, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: s.monthlyQuota)),
        TextField(controller: priceC, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: s.priceSEK)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.save)),
      ],
    ));

    if (result == true) {
      await sl<ApiClient>().dio.put(ApiEndpoints.adminProductById(p['id']), data: {
        'name': nameC.text,
        'description': descC.text,
        'monthlyQuota': int.tryParse(quotaC.text),
        'priceSEK': double.tryParse(priceC.text),
      });
      _load();
    }
  }
}

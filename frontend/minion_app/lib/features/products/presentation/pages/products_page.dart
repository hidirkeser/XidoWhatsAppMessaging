import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _individualProducts = [];
  List<dynamic> _corporateProducts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final response = await sl<ApiClient>().dio.get(ApiEndpoints.products);
      final products = response.data as List;
      setState(() {
        _individualProducts = products.where((p) => p['type'] == 'Individual').toList();
        _corporateProducts = products.where((p) => p['type'] == 'Corporate').toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.products),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: s.individual),
            Tab(text: s.corporate),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProductList(_individualProducts, false),
                _buildProductList(_corporateProducts, true),
              ],
            ),
    );
  }

  Widget _buildProductList(List<dynamic> products, bool isCorporate) {
    final s = AppL10n.of(context)!;
    final theme = Theme.of(context);

    if (products.isEmpty) {
      return Center(child: Text(s.noProductsAvailable));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length + (isCorporate ? 1 : 0),
      itemBuilder: (context, index) {
        if (isCorporate && index == products.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.business, size: 40, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(s.corporateApiAccess, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(s.corporateApiDescription, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.push('/corporate/apply'),
                      icon: const Icon(Icons.app_registration),
                      label: Text(s.applyNow),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final p = products[index];
        final features = _parseFeatures(p['features']);
        final price = (p['priceSEK'] as num?)?.toDouble() ?? 0;
        final quota = p['monthlyQuota'] as int? ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p['name'] ?? '', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      price == 0 ? s.free : '${price.toStringAsFixed(0)} SEK/${s.month}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (p['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(p['description'], style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                ],
                const SizedBox(height: 8),
                Text(
                  quota >= 999999 ? '${s.unlimited} ${s.operationsPerMonth}' : '$quota ${s.operationsPerMonth}',
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (features.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                        const SizedBox(width: 8),
                        Expanded(child: Text(f, style: theme.textTheme.bodySmall)),
                      ],
                    ),
                  )),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _purchaseProduct(p),
                    child: Text(price == 0 ? s.activateFree : s.subscribe),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> _parseFeatures(dynamic features) {
    if (features == null) return [];
    if (features is List) return features.cast<String>();
    if (features is String) {
      try {
        final parsed = jsonDecode(features);
        if (parsed is List) return parsed.cast<String>();
      } catch (_) {}
    }
    return [];
  }

  Future<void> _purchaseProduct(dynamic product) async {
    final price = (product['priceSEK'] as num?)?.toDouble() ?? 0;
    if (price == 0) {
      // Free plan — activate directly
      try {
        await sl<ApiClient>().dio.post(ApiEndpoints.subscriptionsPurchase, data: {
          'productId': product['id'],
          'provider': 'swish',
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppL10n.of(context)!.subscriptionActivated)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error activating subscription')),
          );
        }
      }
    } else {
      // Paid plan — go to purchase page with product ID
      context.push('/subscriptions/purchase/${product['id']}');
    }
  }
}

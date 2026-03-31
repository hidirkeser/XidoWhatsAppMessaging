import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../l10n/generated/app_localizations.dart';

class PurchaseSubscriptionPage extends StatefulWidget {
  final String productId;
  const PurchaseSubscriptionPage({super.key, required this.productId});

  @override
  State<PurchaseSubscriptionPage> createState() => _PurchaseSubscriptionPageState();
}

class _PurchaseSubscriptionPageState extends State<PurchaseSubscriptionPage> {
  Map<String, dynamic>? _product;
  String _selectedProvider = 'swish';
  bool _loading = true;
  bool _processing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final response = await sl<ApiClient>().dio.get(ApiEndpoints.productById(widget.productId));
      setState(() { _product = response.data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _purchase() async {
    final s = AppL10n.of(context)!;
    setState(() { _processing = true; _error = null; });

    try {
      final response = await sl<ApiClient>().dio.post(ApiEndpoints.subscriptionsPurchase, data: {
        'productId': widget.productId,
        'provider': _selectedProvider,
      });

      final data = response.data;
      if (data['status'] == 'activated') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.subscriptionActivated)),
          );
          context.go('/home');
        }
      } else if (data['paymentUrl'] != null) {
        // Redirect to payment URL (for PayPal/Klarna)
        // For Swish, show QR code
        if (_selectedProvider == 'swish' && data['qrData'] != null) {
          _showSwishDialog(data);
        } else {
          // Open external payment URL
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(s.redirectingToPayment)),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _processing = false);
    }
  }

  void _showSwishDialog(dynamic data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(AppL10n.of(context)!.swishPayment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppL10n.of(context)!.waitingForPayment),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppL10n.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.subscribe)),
        body: Center(child: Text(s.productNotFound)),
      );
    }

    final price = (_product!['priceSEK'] as num?)?.toDouble() ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(s.subscribe)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_product!['name'] ?? '', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${price.toStringAsFixed(0)} SEK/${s.month}',
                      style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
                    if (_product!['description'] != null) ...[
                      const SizedBox(height: 8),
                      Text(_product!['description'], style: theme.textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(s.selectPaymentMethod, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...['swish', 'paypal', 'klarna'].map((provider) => RadioListTile<String>(
              title: Text(provider[0].toUpperCase() + provider.substring(1)),
              value: provider,
              groupValue: _selectedProvider,
              onChanged: (v) => setState(() => _selectedProvider = v!),
            )),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _processing ? null : _purchase,
                child: _processing
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(s.confirmPurchase),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

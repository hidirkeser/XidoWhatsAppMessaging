import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../cubit/credit_cubit.dart';

// Payment flow states
enum _PayState { idle, processing, waitingPayment, success, error }

class PurchaseCreditsPage extends StatefulWidget {
  const PurchaseCreditsPage({super.key});

  @override
  State<PurchaseCreditsPage> createState() => _PurchaseCreditsPageState();
}

class _PurchaseCreditsPageState extends State<PurchaseCreditsPage> {
  List<dynamic> _packages = [];
  String _selectedProvider = 'swish';
  bool _loading = true;

  // Swish payment state
  _PayState _payState = _PayState.idle;
  dynamic _selectedPackage;
  String? _instructionId;
  String? _qrData;
  String? _errorMsg;
  final _phoneController = TextEditingController();
  Timer? _pollTimer;
  int _pollCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    try {
      final response = await sl<ApiClient>().dio.get(ApiEndpoints.creditsPackages);
      setState(() {
        _packages = response.data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _initiatePurchase(dynamic package) async {
    setState(() {
      _payState = _PayState.processing;
      _selectedPackage = package;
      _errorMsg = null;
    });

    try {
      final response = await sl<ApiClient>().dio.post(
        ApiEndpoints.creditsPurchase,
        data: {
          'creditPackageId': package['id'],
          'provider': _selectedProvider,
          if (_selectedProvider == 'swish' && _phoneController.text.isNotEmpty)
            'payerPhone': _phoneController.text.trim(),
        },
      );

      final data = response.data;
      final externalId = data['externalPaymentId'] as String?;
      final qrData = data['qrData'] as String?;
      final paymentUrl = data['paymentUrl'] as String?;

      if (_selectedProvider == 'swish') {
        setState(() {
          _instructionId = externalId;
          _qrData = qrData;
          _payState = _PayState.waitingPayment;
          _pollCount = 0;
        });
        _startPolling();
      } else if (paymentUrl != null) {
        // PayPal / Klarna — open in browser
        final uri = Uri.tryParse(paymentUrl);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        setState(() => _payState = _PayState.idle);
      } else {
        setState(() => _payState = _PayState.idle);
      }
    } catch (e) {
      setState(() {
        _payState = _PayState.error;
        _errorMsg = e.toString();
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_instructionId == null) return;
      _pollCount++;
      // Stop after 3 minutes (90 polls * 2s)
      if (_pollCount > 90) {
        _pollTimer?.cancel();
        setState(() {
          _payState = _PayState.error;
          _errorMsg = 'Ödeme zaman aşımına uğradı. Lütfen tekrar deneyin.';
        });
        return;
      }
      await _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    if (_instructionId == null) return;
    try {
      final response = await sl<ApiClient>().dio.get(
        '${ApiEndpoints.creditsBase}/swish/status/$_instructionId',
      );
      final status = response.data['status'] as String? ?? '';

      if (status == 'Completed') {
        _pollTimer?.cancel();
        if (mounted) {
          context.read<CreditCubit>().loadBalance();
          setState(() => _payState = _PayState.success);
        }
      } else if (status == 'Failed' || status == 'Cancelled') {
        _pollTimer?.cancel();
        if (mounted) {
          setState(() {
            _payState = _PayState.error;
            _errorMsg = response.data['errorMessage'] ?? 'Ödeme başarısız.';
          });
        }
      }
    } catch (_) {
      // ignore transient errors
    }
  }

  void _reset() {
    _pollTimer?.cancel();
    setState(() {
      _payState = _PayState.idle;
      _instructionId = null;
      _qrData = null;
      _selectedPackage = null;
      _errorMsg = null;
      _pollCount = 0;
    });
  }

  Future<void> _openSwishApp() async {
    if (_qrData == null) return;
    // Try swish:// deep link first
    final uri = Uri.tryParse(_qrData!);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return switch (_payState) {
      _PayState.processing => _buildProcessing(),
      _PayState.waitingPayment => _buildWaitingPayment(context),
      _PayState.success => _buildSuccess(context),
      _PayState.error => _buildError(context),
      _ => _buildPackageList(context),
    };
  }

  // ── Package list (idle) ────────────────────────────────────────────────────
  Widget _buildPackageList(BuildContext context) {
    final s = AppL10n.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provider selector
          Text(s.paymentMethod,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildProviderSelector(s),
          const SizedBox(height: 8),

          // Swish phone input
          if (_selectedProvider == 'swish') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Swish numarası (isteğe bağlı)',
                hintText: '+46 70 123 45 67',
                prefixIcon: Icon(Icons.phone, color: cs.primary),
                helperText: 'Boş bırakırsanız QR kod ile ödeme yapılır',
              ),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))],
            ),
          ],

          const SizedBox(height: 24),

          // Packages
          Text(s.creditPackages,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (_packages.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(s.noPackagesFound,
                      style: TextStyle(color: Colors.grey[500])),
                ),
              ),
            ),

          ..._packages.map((p) => _buildPackageCard(p, s, cs)),
        ],
      ),
    );
  }

  Widget _buildProviderSelector(AppL10n s) {
    final providers = [
      {'id': 'swish', 'label': 'Swish', 'color': const Color(0xFF43B02A)},
      {'id': 'paypal', 'label': 'PayPal', 'color': const Color(0xFF003087)},
      {'id': 'klarna', 'label': 'Klarna', 'color': const Color(0xFFFF8181)},
    ];

    return Row(
      children: providers.map((p) {
        final isSelected = _selectedProvider == p['id'];
        final color = p['color'] as Color;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedProvider = p['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      p['id'] == 'swish' ? Icons.phone_android
                          : p['id'] == 'paypal' ? Icons.payment
                          : Icons.shopping_bag,
                      color: isSelected ? Colors.white : color,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPackageCard(dynamic package, AppL10n s, ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Credit amount badge
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${package['creditAmount']}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                    ),
                  ),
                  Text('kr', style: TextStyle(fontSize: 10, color: cs.primary)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(package['name'],
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  if (package['description'] != null) ...[
                    const SizedBox(height: 2),
                    Text(package['description'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => _initiatePurchase(package),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text('${package['priceSEK']} SEK',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Processing ────────────────────────────────────────────────────────────
  Widget _buildProcessing() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Ödeme başlatılıyor...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // ── Waiting for Swish payment ─────────────────────────────────────────────
  Widget _buildWaitingPayment(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Package info
            if (_selectedPackage != null)
              Card(
                color: cs.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedPackage!['creditAmount']} kontor — ${_selectedPackage!['priceSEK']} SEK',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: cs.primary),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // QR Code
            if (_qrData != null) ...[
              Text('QR Kod ile Ödeme',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Swish uygulamanızı açıp QR kodu tarayın',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: QrImageView(
                  data: _qrData!,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Open Swish button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _openSwishApp,
                icon: const Icon(Icons.phone_android),
                label: const Text('Swish Uygulamasını Aç',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF43B02A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Polling indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: cs.primary),
                ),
                const SizedBox(width: 10),
                Text('Ödeme bekleniyor...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),

            const SizedBox(height: 8),
            Text('${3 - (_pollCount * 2 / 60).floor()} dakika kaldı',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),

            const SizedBox(height: 24),

            // Cancel
            TextButton(
              onPressed: _reset,
              child: Text('İptal',
                  style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        ),
      ),
    );
  }

  // ── Success ───────────────────────────────────────────────────────────────
  Widget _buildSuccess(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle,
                  size: 48, color: Colors.green[600]),
            ),
            const SizedBox(height: 20),
            Text('Ödeme Başarılı!',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (_selectedPackage != null)
              Text(
                '${_selectedPackage!['creditAmount']} kontor hesabınıza eklendi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Paketlere Dön'),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: Colors.red[600]),
            ),
            const SizedBox(height: 20),
            Text('Ödeme Başarısız',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            if (_errorMsg != null) ...[
              const SizedBox(height: 8),
              Text(_errorMsg!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

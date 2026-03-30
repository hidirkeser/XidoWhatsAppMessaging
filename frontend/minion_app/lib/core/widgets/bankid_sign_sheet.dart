import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/generated/app_localizations.dart';
import '../di/injection_container.dart';
import '../network/api_client.dart';

class BankIdSignSheet extends StatefulWidget {
  final String userVisibleText;
  final Future<void> Function(String orderRef, String signature) onComplete;

  const BankIdSignSheet({
    super.key,
    required this.userVisibleText,
    required this.onComplete,
  });

  static Future<bool> show(
    BuildContext context, {
    required String userVisibleText,
    required Future<void> Function(String orderRef, String signature) onComplete,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BankIdSignSheet(
        userVisibleText: userVisibleText,
        onComplete: onComplete,
      ),
    );
    return result ?? false;
  }

  @override
  State<BankIdSignSheet> createState() => _BankIdSignSheetState();
}

enum _SignState { initializing, waiting, completing, error }

class _BankIdSignSheetState extends State<BankIdSignSheet> {
  _SignState _state = _SignState.initializing;
  String? _orderRef;
  String? _autoStartToken;
  String? _qrData;
  String? _errorMessage;
  bool _sameDevice = false;
  Timer? _pollingTimer;
  Timer? _qrTimer;

  @override
  void initState() {
    super.initState();
    _initSign();
  }

  Future<void> _initSign() async {
    try {
      final response = await sl<ApiClient>().dio.post('/auth/sign/init', data: {
        'userVisibleData': widget.userVisibleText,
      });
      _orderRef = response.data['orderRef'] as String;
      _autoStartToken = response.data['autoStartToken'] as String?;
      _qrData = response.data['qrData'] as String?;
      if (mounted) setState(() => _state = _SignState.waiting);
      _launchBankId();
      _startPolling();
      _startQrRefresh();
    } catch (e) {
      if (mounted) setState(() {
        _state = _SignState.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  void _startQrRefresh() {
    _qrTimer = Timer.periodic(const Duration(seconds: 1), (_) => _refreshQr());
  }

  Future<void> _refreshQr() async {
    if (_orderRef == null) return;
    try {
      final response = await sl<ApiClient>().dio.get('/auth/qr/$_orderRef');
      if (mounted) setState(() => _qrData = response.data['qrData'] as String?);
    } catch (_) {}
  }

  Future<void> _poll() async {
    if (_orderRef == null) return;
    try {
      final response = await sl<ApiClient>().dio.post('/auth/sign/collect', data: {
        'orderRef': _orderRef,
      });
      final status = response.data['status'] as String?;

      if (status == 'complete') {
        _pollingTimer?.cancel();
        _qrTimer?.cancel();
        final signature = response.data['signature'] as String? ?? '';
        if (mounted) setState(() => _state = _SignState.completing);
        if (mounted) Navigator.of(context).pop(true);
        await widget.onComplete(_orderRef!, signature);
      } else if (status == 'failed') {
        _pollingTimer?.cancel();
        _qrTimer?.cancel();
        if (mounted) setState(() {
          _state = _SignState.error;
          _errorMessage = response.data['hintCode'] as String? ?? 'failed';
        });
      }
    } catch (_) {}
  }

  Future<void> _launchBankId() async {
    if (_autoStartToken == null || kIsWeb) return;
    final uri = Uri.parse('bankid:///?autostarttoken=$_autoStartToken&redirect=null');
    if (await canLaunchUrl(uri)) {
      _sameDevice = true;
      if (mounted) setState(() {});
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _cancel() async {
    _pollingTimer?.cancel();
    _qrTimer?.cancel();
    if (_orderRef != null) {
      try {
        await sl<ApiClient>().dio.post('/auth/cancel', data: {'orderRef': _orderRef});
      } catch (_) {}
    }
    if (mounted) Navigator.of(context).pop(false);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _qrTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),

          if (_state == _SignState.initializing || _state == _SignState.waiting || _state == _SignState.completing) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cs.primaryContainer, shape: BoxShape.circle),
              child: Icon(Icons.fingerprint, size: 48, color: cs.primary),
            ),
            const SizedBox(height: 20),
            Text(
              s.bankIdSignTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _state == _SignState.completing ? s.bankIdSignCompleting : s.bankIdSignWaiting,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // QR code — only for other device (canLaunchUrl returned false)
            if (_state == _SignState.waiting && !_sameDevice && _qrData != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: QrImageView(data: _qrData!, size: 180),
              ),
              const SizedBox(height: 8),
              Text(
                s.scanQrCode,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            const LinearProgressIndicator(),
            const SizedBox(height: 16),

            if (_state == _SignState.waiting) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _launchBankId,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(s.openBankIdApp),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextButton(
              onPressed: _cancel,
              child: Text(s.cancel, style: const TextStyle(color: Colors.grey)),
            ),
          ] else if (_state == _SignState.error) ...[
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(s.bankIdSignError, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_errorMessage ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(s.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() { _state = _SignState.initializing; _errorMessage = null; });
                      _initSign();
                    },
                    child: Text(s.retry),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

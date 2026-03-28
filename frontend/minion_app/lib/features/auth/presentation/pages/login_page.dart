import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/widgets/language_selector.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _useOtherDevice = false;
  String? _qrData;
  Timer? _qrTimer;
  String? _currentOrderRef;

  @override
  void dispose() {
    _qrTimer?.cancel();
    super.dispose();
  }

  void _startQrRefresh(String orderRef) {
    _currentOrderRef = orderRef;
    _qrTimer?.cancel();
    _qrTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        final apiClient = sl<ApiClient>();
        final response = await apiClient.dio.get(
          ApiEndpoints.authQr(orderRef),
        );
        if (mounted) {
          setState(() => _qrData = response.data['qrData']);
        }
      } catch (_) {}
    });
  }

  void _stopQrRefresh() {
    _qrTimer?.cancel();
    _qrTimer = null;
    _currentOrderRef = null;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Language selector row at top ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [LanguageSelector(expanded: true)],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user, size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                Text(s.appName, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(s.bankIdAuthSystem, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
                const SizedBox(height: 48),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthError) {
                      _stopQrRefresh();
                      ApiErrorHandler.showError(context, state.message);
                    }
                    if (state is AuthWaitingForBankId) {
                      if (_useOtherDevice) {
                        setState(() => _qrData = state.qrData);
                        _startQrRefresh(state.orderRef);
                      }
                    }
                    if (state is AuthAuthenticated || state is AuthInitial) {
                      _stopQrRefresh();
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthLoading) return const CircularProgressIndicator();
                    if (state is AuthWaitingForBankId) {
                      return _buildWaitingForBankId(context, state, s);
                    }
                    return _buildLoginButton(context, s);
                  },
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => _devLogin(context),
                  icon: const Icon(Icons.developer_mode),
                  label: const Text('Dev Login (Test)'),
                ),
              ],
            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, AppL10n s) {
    return Column(
      children: [
        // Device selector
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(child: _deviceTab(context, icon: Icons.smartphone, label: s.thisDevice, selected: !_useOtherDevice, onTap: () => setState(() => _useOtherDevice = false))),
              Expanded(child: _deviceTab(context, icon: Icons.qr_code_scanner, label: s.otherDevice, selected: _useOtherDevice, onTap: () => setState(() => _useOtherDevice = true))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => context.read<AuthBloc>().add(AuthInitBankId()),
            icon: const Icon(Icons.fingerprint, size: 28),
            label: Text(s.loginWithBankId, style: const TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _deviceTab(BuildContext context, {required IconData icon, required String label, required bool selected, required VoidCallback onTap}) {
    final color = selected ? Theme.of(context).colorScheme.primary : Colors.grey[600]!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Flexible(child: Text(label, style: TextStyle(color: color, fontWeight: selected ? FontWeight.bold : FontWeight.normal), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingForBankId(BuildContext context, AuthWaitingForBankId state, AppL10n s) {
    return Column(
      children: [
        if (_useOtherDevice) ...[
          _buildQrCode(context, s),
        ] else ...[
          Column(children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(s.openingBankIdApp),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _launchBankId(state.autoStartToken),
            child: Text(s.openBankIdApp),
          ),
        ],
        const SizedBox(height: 24),
        const LinearProgressIndicator(),
        const SizedBox(height: 12),
        Text(s.waitingForApproval, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            _stopQrRefresh();
            context.read<AuthBloc>().add(AuthCancel());
          },
          child: Text(s.cancel),
        ),
      ],
    );
  }

  Widget _buildQrCode(BuildContext context, AppL10n s) {
    final qr = _qrData;
    if (qr == null) {
      return const SizedBox(width: 250, height: 250, child: Center(child: CircularProgressIndicator()));
    }
    return Column(
      children: [
        Container(
          width: 250,
          height: 250,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: QrImageView(
            data: qr,
            version: QrVersions.auto,
            size: 226,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(s.scanQrCode, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Future<void> _launchBankId(String autoStartToken) async {
    final uri = Uri.parse('bankid:///?autostarttoken=$autoStartToken&redirect=null');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _devLogin(BuildContext context) async {
    try {
      final apiClient = sl<ApiClient>();
      final response = await apiClient.dio.post('/dev/test-login/199001011234');
      final data = response.data;
      await apiClient.saveTokens(data['accessToken'], '');
      if (context.mounted) {
        context.read<AuthBloc>().add(AuthCheckStatus());
      }
    } catch (e) {
      if (context.mounted) ApiErrorHandler.showError(context, e);
    }
  }
}

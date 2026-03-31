import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/utils/bankid_launcher.dart';
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
  @override
  void dispose() {
    _qrTimer?.cancel();
    super.dispose();
  }

  void _startQrRefresh(String orderRef) {
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary: this device
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => _useOtherDevice = false);
              context.read<AuthBloc>().add(AuthInitBankId());
            },
            icon: const Icon(Icons.fingerprint, size: 28),
            label: Text(s.loginWithBankId, style: const TextStyle(fontSize: 17)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Secondary: other device (QR)
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() => _useOtherDevice = true);
              context.read<AuthBloc>().add(AuthInitBankId());
            },
            icon: const Icon(Icons.qr_code_scanner, size: 22),
            label: Text(s.loginWithBankIdOtherDevice, style: const TextStyle(fontSize: 14)),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
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
    final url = 'bankid:///?autostarttoken=$autoStartToken&redirect=null';
    final opened = await launchBankIdUrl(url);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BankID uygulaması bu cihazda bulunamadı. Lütfen uygulamayı yükleyin.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/language_selector.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/auth_bloc.dart';

class GdprConsentPage extends StatefulWidget {
  const GdprConsentPage({super.key});

  @override
  State<GdprConsentPage> createState() => _GdprConsentPageState();
}

class _GdprConsentPageState extends State<GdprConsentPage> {
  bool _dataProcessingConsent = false;
  bool _marketingConsent = false;
  bool _submitting = false;

  Future<void> _accept() async {
    if (!_dataProcessingConsent) return;
    setState(() => _submitting = true);
    try {
      await sl<ApiClient>().dio.post('/users/me/consent', data: {
        'marketingConsent': _marketingConsent,
      });
      if (mounted) {
        context.read<AuthBloc>().add(AuthConsentAccepted());
      }
    } catch (e) {
      if (mounted) await AppDialog.showError(context, e);
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 16, 0),
                child: LanguageSelector(expanded: false),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Center(
                      child: Icon(Icons.shield_outlined, size: 72, color: cs.primary),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        s.gdprTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        s.gdprSubtitle,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Data processing section
                    _SectionCard(
                      icon: Icons.person_outline,
                      title: s.gdprDataProcessingTitle,
                      body: s.gdprDataProcessingBody,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.lock_outline,
                      title: s.gdprSecurityTitle,
                      body: s.gdprSecurityBody,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.delete_outline,
                      title: s.gdprRightsTitle,
                      body: s.gdprRightsBody,
                    ),
                    const SizedBox(height: 24),

                    // Required consent
                    _ConsentCheckbox(
                      value: _dataProcessingConsent,
                      onChanged: (v) => setState(() => _dataProcessingConsent = v ?? false),
                      label: s.gdprRequiredConsentLabel,
                      required: true,
                    ),
                    const SizedBox(height: 12),
                    // Optional marketing consent
                    _ConsentCheckbox(
                      value: _marketingConsent,
                      onChanged: (v) => setState(() => _marketingConsent = v ?? false),
                      label: s.gdprMarketingConsentLabel,
                      required: false,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom action area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_dataProcessingConsent && !_submitting) ? _accept : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _submitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(s.gdprAcceptButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.gdprFootnote,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _SectionCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: cs.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final bool required;

  const _ConsentCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.required,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: value ? cs.primaryContainer.withValues(alpha: 0.5) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? cs.primary.withValues(alpha: 0.5) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(value: value, onChanged: onChanged),
          const SizedBox(width: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  children: [
                    if (required)
                      TextSpan(
                        text: '* ',
                        style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.bold),
                      ),
                    TextSpan(
                      text: label,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

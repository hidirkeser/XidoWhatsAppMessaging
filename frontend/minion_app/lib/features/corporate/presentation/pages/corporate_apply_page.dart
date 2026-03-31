import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../l10n/generated/app_localizations.dart';

class CorporateApplyPage extends StatefulWidget {
  const CorporateApplyPage({super.key});

  @override
  State<CorporateApplyPage> createState() => _CorporateApplyPageState();
}

class _CorporateApplyPageState extends State<CorporateApplyPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameC = TextEditingController();
  final _orgNumberC = TextEditingController();
  final _contactNameC = TextEditingController();
  final _contactEmailC = TextEditingController();
  final _contactPhoneC = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _companyNameC.dispose();
    _orgNumberC.dispose();
    _contactNameC.dispose();
    _contactEmailC.dispose();
    _contactPhoneC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final s = AppL10n.of(context)!;

    setState(() => _submitting = true);

    try {
      await sl<ApiClient>().dio.post(ApiEndpoints.corporateApply, data: {
        'companyName': _companyNameC.text,
        'orgNumber': _orgNumberC.text,
        'contactName': _contactNameC.text,
        'contactEmail': _contactEmailC.text,
        'contactPhone': _contactPhoneC.text.isNotEmpty ? _contactPhoneC.text : null,
      });
      setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.applicationError)),
        );
      }
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    final theme = Theme.of(context);

    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: Text(s.corporateApplication)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 80, color: Colors.green[600]),
                const SizedBox(height: 24),
                Text(s.applicationSubmitted, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(s.applicationSubmittedMessage, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => context.go('/home'),
                  child: Text(s.backToHome),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.corporateApplication)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(child: Text(s.corporateApplyInfo, style: theme.textTheme.bodySmall)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(s.companyInformation, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyNameC,
                decoration: InputDecoration(labelText: s.companyName, prefixIcon: const Icon(Icons.business)),
                validator: (v) => v == null || v.isEmpty ? s.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _orgNumberC,
                decoration: InputDecoration(labelText: s.orgNumber, prefixIcon: const Icon(Icons.numbers)),
                validator: (v) => v == null || v.isEmpty ? s.required : null,
              ),
              const SizedBox(height: 24),
              Text(s.contactInformation, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNameC,
                decoration: InputDecoration(labelText: s.contactName, prefixIcon: const Icon(Icons.person)),
                validator: (v) => v == null || v.isEmpty ? s.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactEmailC,
                decoration: InputDecoration(labelText: s.contactEmail, prefixIcon: const Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return s.required;
                  if (!v.contains('@')) return s.invalidEmail;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactPhoneC,
                decoration: InputDecoration(labelText: s.contactPhone, prefixIcon: const Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  label: Text(s.submitApplication),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

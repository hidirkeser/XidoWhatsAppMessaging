import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
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

  // Form controllers
  final _companyNameC  = TextEditingController();
  final _orgNumberC    = TextEditingController();
  final _contactNameC  = TextEditingController();
  final _contactEmailC = TextEditingController();
  final _contactPhoneC = TextEditingController();
  final _otpC          = TextEditingController();

  // State
  bool _otpSent      = false;
  bool _phoneVerified = false;
  bool _sendingOtp   = false;
  bool _verifyingOtp = false;
  bool _submitting   = false;
  bool _submitted    = false;
  String? _submittedId;

  // Documents: { type -> { name, bytes } }
  final Map<String, PlatformFile?> _docs = {
    'RegistrationCertificate': null,
    'SignatoryDocument': null,
    'IdentityDocument': null,
  };

  static const _docLabels = {
    'RegistrationCertificate': 'Registreringsbevis / Ticaret Sicil',
    'SignatoryDocument':       'Firmatecknare / İmza Sirküleri',
    'IdentityDocument':        'Kimlik Belgesi (opsiyonel)',
  };
  static const _docRequired = {
    'RegistrationCertificate': true,
    'SignatoryDocument':        true,
    'IdentityDocument':         false,
  };

  @override
  void dispose() {
    _companyNameC.dispose(); _orgNumberC.dispose();
    _contactNameC.dispose(); _contactEmailC.dispose();
    _contactPhoneC.dispose(); _otpC.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _contactPhoneC.text.trim();
    if (phone.isEmpty) {
      _showError('Lütfen telefon numarası girin.');
      return;
    }
    setState(() => _sendingOtp = true);
    try {
      await sl<ApiClient>().dio.post(ApiEndpoints.corporateOtpSend, data: {'phone': phone});
      setState(() => _otpSent = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doğrulama kodu gönderildi.')));
    } catch (e) {
      _showError(_extractError(e, 'OTP gönderilemedi.'));
    } finally {
      setState(() => _sendingOtp = false);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _verifyingOtp = true);
    try {
      await sl<ApiClient>().dio.post(ApiEndpoints.corporateOtpVerify, data: {
        'phone': _contactPhoneC.text.trim(),
        'code':  _otpC.text.trim(),
      });
      setState(() => _phoneVerified = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefon numarası doğrulandı ✓')));
    } catch (e) {
      _showError(_extractError(e, 'Geçersiz kod.'));
    } finally {
      setState(() => _verifyingOtp = false);
    }
  }

  Future<void> _pickDocument(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _docs[type] = result.files.first);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Check required docs
    for (final entry in _docRequired.entries) {
      if (entry.value && _docs[entry.key] == null) {
        _showError('Lütfen ${_docLabels[entry.key]} belgesi yükleyin.');
        return;
      }
    }

    if (_contactPhoneC.text.isNotEmpty && !_phoneVerified) {
      _showError('Lütfen önce telefon numaranızı doğrulayın.');
      return;
    }

    setState(() => _submitting = true);
    try {
      // Build documentsJson list
      final docsJson = <Map<String, dynamic>>[];
      for (final entry in _docs.entries) {
        final file = entry.value;
        if (file == null) continue;
        // In a real app, upload file to storage first and get path.
        // Here we store filename + base64 (small files only).
        docsJson.add({
          'type':       entry.key,
          'name':       file.name,
          'uploadedAt': DateTime.now().toIso8601String(),
        });
      }

      final res = await sl<ApiClient>().dio.post(ApiEndpoints.corporateApply, data: {
        'companyName':  _companyNameC.text,
        'orgNumber':    _orgNumberC.text,
        'contactName':  _contactNameC.text,
        'contactEmail': _contactEmailC.text,
        'contactPhone': _contactPhoneC.text.isNotEmpty ? _contactPhoneC.text : null,
        'documentsJson': jsonEncode(docsJson),
      });

      setState(() {
        _submitted = true;
        _submittedId = res.data['id'] as String?;
      });
    } catch (e) {
      _showError(_extractError(e, 'Başvuru gönderilemedi.'));
    } finally {
      setState(() => _submitting = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
  }

  String _extractError(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) return data['message'] ?? data['detail'] ?? fallback;
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final s     = AppL10n.of(context)!;
    final theme = Theme.of(context);

    if (_submitted) return _buildSuccess(context, theme, s);

    return Scaffold(
      appBar: AppBar(title: Text(s.corporateApplication)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Card(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(s.corporateApplyInfo, style: theme.textTheme.bodySmall)),
                  ]),
                ),
              ),
              const SizedBox(height: 24),

              // ── Company info ─────────────────────────────────────────────
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

              // ── Contact info ─────────────────────────────────────────────
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

              // ── Phone + OTP ───────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _contactPhoneC,
                      decoration: InputDecoration(
                        labelText: '${s.contactPhone} *',
                        prefixIcon: const Icon(Icons.phone),
                        suffixIcon: _phoneVerified
                            ? const Icon(Icons.verified, color: Colors.green)
                            : null,
                      ),
                      keyboardType: TextInputType.phone,
                      enabled: !_phoneVerified,
                      validator: (v) => v == null || v.isEmpty ? s.required : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!_phoneVerified)
                    SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _sendingOtp ? null : _sendOtp,
                        child: _sendingOtp
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(_otpSent ? 'Tekrar Gönder' : 'Kodu Gönder'),
                      ),
                    ),
                ],
              ),

              if (_otpSent && !_phoneVerified) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _otpC,
                        decoration: const InputDecoration(
                          labelText: 'Doğrulama Kodu',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        onPressed: _verifyingOtp ? null : _verifyOtp,
                        child: _verifyingOtp
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Doğrula'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // ── Documents ─────────────────────────────────────────────────
              Text('Belgeler', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Lütfen aşağıdaki belgeleri yükleyin (PDF, JPG, PNG — maks. 10 MB).',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ..._docs.keys.map((type) => _buildDocRow(context, theme, type)),
              const SizedBox(height: 32),

              // ── Submit ────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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

  Widget _buildDocRow(BuildContext context, ThemeData theme, String type) {
    final file     = _docs[type];
    final label    = _docLabels[type]!;
    final required = _docRequired[type]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: file != null ? Colors.green : (required ? theme.colorScheme.outline : Colors.grey[300]!),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    file != null ? Icons.check_circle : Icons.upload_file,
                    size: 20,
                    color: file != null ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      file != null ? file.name : label,
                      style: TextStyle(
                        fontSize: 13,
                        color: file != null ? Colors.green[700] : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!required)
                    Text(' (opsiyonel)', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _pickDocument(type),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
            child: Text(file != null ? 'Değiştir' : 'Seç'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, ThemeData theme, AppL10n s) {
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
              Text(s.applicationSubmitted,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(s.applicationSubmittedMessage,
                  textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
              if (_submittedId != null) ...[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => context.push('/corporate/applications/$_submittedId'),
                  icon: const Icon(Icons.track_changes),
                  label: const Text('Başvuru Durumunu Takip Et'),
                ),
              ],
              const SizedBox(height: 16),
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
}

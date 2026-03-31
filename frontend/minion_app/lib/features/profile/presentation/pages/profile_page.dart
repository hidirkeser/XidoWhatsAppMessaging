import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/cubit/language_cubit.dart';
import '../../../../core/cubit/theme_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../cubit/avatar_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AvatarCubit>(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    final authState = context.watch<AuthBloc>().state;
    final auth = authState is AuthAuthenticated ? authState : null;

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Hero avatar section ──────────────────────────────────────────
          _AvatarSection(auth: auth),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // ── User info card ───────────────────────────────────────
                _InfoCard(auth: auth, s: s),

                const SizedBox(height: 16),

                // ── Language selector card ───────────────────────────────
                _LanguageCard(s: s),

                const SizedBox(height: 16),

                // ── Theme selector card ──────────────────────────────────
                _ThemeCard(s: s),

                const SizedBox(height: 16),

                // ── Notification preferences card ────────────────────────
                _NotificationSettingsCard(s: s),

                const SizedBox(height: 24),

                // ── Logout button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.read<AuthBloc>().add(AuthLogout()),
                    icon: Icon(Icons.logout, color: Colors.red[600]),
                    label: Text(
                      s.logout,
                      style: TextStyle(
                          color: Colors.red[600],
                          fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[300]!),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar hero section ──────────────────────────────────────────────────────
class _AvatarSection extends StatelessWidget {
  final AuthAuthenticated? auth;
  const _AvatarSection({required this.auth});

  @override
  Widget build(BuildContext context) {
    final avatarPath = context.watch<AvatarCubit>().state;
    final themeState = context.watch<ThemeCubit>().state;
    final gradColors = AppTheme.gradientOf(themeState.type);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradColors,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
          child: Column(
            children: [
              // ── Avatar with camera button ──
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.white.withValues(alpha:0.2),
                      backgroundImage: _resolveImage(avatarPath),
                      child: _resolveImage(avatarPath) == null
                          ? Text(
                              auth != null && auth!.firstName.isNotEmpty
                                  ? auth!.firstName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                  // Camera button
                  GestureDetector(
                    onTap: () => _showImageSourceSheet(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: gradColors.first.withValues(alpha: 0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.camera_alt_rounded,
                          size: 18, color: gradColors.first),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Name ──
              Text(
                auth != null
                    ? '${auth!.firstName} ${auth!.lastName}'.trim()
                    : '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 4),

              // ── Personnummer ──
              if (auth != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    auth!.personalNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _resolveImage(String? path) {
    if (path == null || kIsWeb) return null;
    final file = File(path);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library_outlined,
                      color: Theme.of(context).colorScheme.primary),
                ),
                title: const Text('Galeri',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Fotoğraf kitaplığından seç'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt_outlined,
                      color: Colors.orange[700]),
                ),
                title: const Text('Kamera',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Fotoğraf çek'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              if (context.read<AvatarCubit>().state != null) ...[
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete_outline,
                        color: Colors.red[600]),
                  ),
                  title: Text('Fotoğrafı Kaldır',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red[600])),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AvatarCubit>().clearAvatar();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (file != null && context.mounted) {
        context.read<AvatarCubit>().setAvatar(file.path);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      if (context.mounted) {
        await AppDialog.show(context,
            type: DialogType.error, message: 'Fotoğraf seçilemedi: $e');
      }
    }
  }
}

// ─── User info card (editable) ────────────────────────────────────────────────
class _InfoCard extends StatefulWidget {
  final AuthAuthenticated? auth;
  final AppL10n s;
  const _InfoCard({required this.auth, required this.s});

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard> {
  bool _editing = false;
  bool _saving = false;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final a = widget.auth;
    _firstName = TextEditingController(text: a?.firstName ?? '');
    _lastName  = TextEditingController(text: a?.lastName  ?? '');
    _email     = TextEditingController(text: a?.email     ?? '');
    _phone     = TextEditingController(text: a?.phone     ?? '');
  }

  @override
  void didUpdateWidget(_InfoCard old) {
    super.didUpdateWidget(old);
    if (!_editing) {
      final a = widget.auth;
      _firstName.text = a?.firstName ?? '';
      _lastName.text  = a?.lastName  ?? '';
      _email.text     = a?.email     ?? '';
      _phone.text     = a?.phone     ?? '';
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    setState(() => _saving = true);
    try {
      final response = await sl<ApiClient>().dio.put(
        ApiEndpoints.usersMe,
        data: {
          'firstName': _firstName.text.trim(),
          'lastName':  _lastName.text.trim(),
          'email':     _email.text.trim(),
          'phone':     _phone.text.trim(),
        },
      );
      if (!context.mounted) return;
      final u = response.data as Map<String, dynamic>;
      context.read<AuthBloc>().add(AuthProfileSynced(
        firstName: u['firstName'] as String? ?? _firstName.text.trim(),
        lastName:  u['lastName']  as String? ?? _lastName.text.trim(),
        email:     u['email']     as String? ?? _email.text.trim(),
        phone:     u['phone']     as String? ?? _phone.text.trim(),
      ));
      setState(() => _editing = false);
      await AppDialog.showSuccess(context, widget.s.profileUpdated);
    } catch (e) {
      if (context.mounted) {
        await AppDialog.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person_outline, size: 18, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.s.editInfo,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                if (!_editing)
                  TextButton.icon(
                    onPressed: () => setState(() => _editing = true),
                    icon: Icon(Icons.edit_outlined, size: 16, color: cs.primary),
                    label: Text(widget.s.editProfile,
                        style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (!_editing) ...[
              // ── Read-only rows ──
              _readRow(context, Icons.badge_outlined, widget.s.fullName,
                  widget.auth != null
                      ? '${widget.auth!.firstName} ${widget.auth!.lastName}'.trim()
                      : widget.s.loading),
              _divider(),
              _readRow(context, Icons.credit_card_outlined, widget.s.personnummer,
                  widget.auth?.personalNumber ?? '---'),
              _divider(),
              _readRow(context, Icons.email_outlined, widget.s.email,
                  widget.auth?.email.isNotEmpty == true ? widget.auth!.email : widget.s.notSpecified),
              _divider(),
              _readRow(context, Icons.phone_outlined, widget.s.phone,
                  widget.auth?.phone.isNotEmpty == true ? widget.auth!.phone : widget.s.notSpecified),
            ] else ...[
              // ── Edit fields ──
              _field(context, widget.s.firstName, _firstName, Icons.person_outline,
                  TextInputType.name),
              const SizedBox(height: 12),
              _field(context, widget.s.lastName, _lastName, Icons.person_outline,
                  TextInputType.name),
              const SizedBox(height: 12),
              _field(context, widget.s.email, _email, Icons.email_outlined,
                  TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(context, widget.s.phone, _phone, Icons.phone_outlined,
                  TextInputType.phone),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () {
                        final a = widget.auth;
                        _firstName.text = a?.firstName ?? '';
                        _lastName.text  = a?.lastName  ?? '';
                        _email.text     = a?.email     ?? '';
                        _phone.text     = a?.phone     ?? '';
                        setState(() => _editing = false);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cs.outline),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(widget.s.cancel,
                          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : () => _save(context),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(widget.s.saveChanges,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 48, endIndent: 0);

  Widget _readRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(BuildContext context, String label, TextEditingController ctrl,
      IconData icon, TextInputType type) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: cs.primary),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ─── Language selector card ───────────────────────────────────────────────────
class _LanguageCard extends StatelessWidget {
  final AppL10n s;
  const _LanguageCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        final langs = LanguageCubit.supportedLocales;
        final current = langs.firstWhere(
          (l) => l.code == locale.languageCode,
          orElse: () => langs.first,
        );

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.language,
                          size: 18,
                          color:
                              Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      s.appLanguage,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Dropdown
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: current.code,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      items: langs
                          .map(
                            (l) => DropdownMenuItem<String>(
                              value: l.code,
                              child: Row(
                                children: [
                                  Text(l.flag,
                                      style: const TextStyle(
                                          fontSize: 22)),
                                  const SizedBox(width: 12),
                                  Text(
                                    l.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${l.code.toUpperCase()})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (code) {
                        if (code != null) {
                          context
                              .read<LanguageCubit>()
                              .setLocale(Locale(code));
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Notification settings card ──────────────────────────────────────────────
class _NotificationSettingsCard extends StatelessWidget {
  final AppL10n s;
  const _NotificationSettingsCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.notifications_outlined, size: 18, color: cs.primary),
        ),
        title: const Text('Bildirim Ayarları', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: const Text('Push, e-posta, WhatsApp ve SMS tercihlerini ayarlayın',
            style: TextStyle(fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: cs.primary),
        onTap: () => context.push('/notifications/preferences'),
      ),
    );
  }
}

// ─── Theme + Appearance selector card ────────────────────────────────────────
class _ThemeCard extends StatelessWidget {
  final AppL10n s;
  const _ThemeCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final currentType = themeState.type;
        final currentMode = themeState.mode;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cs.outlineVariant, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.palette_outlined, size: 18, color: cs.primary),
                    ),
                    const SizedBox(width: 12),
                    Text(s.appearance, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Mode selector (Light / Dark / System) ──
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<AppThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: AppThemeMode.light,
                        icon: const Icon(Icons.light_mode, size: 18),
                        label: Text(s.lightMode),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.dark,
                        icon: const Icon(Icons.dark_mode, size: 18),
                        label: Text(s.darkMode),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.system,
                        icon: const Icon(Icons.phone_android, size: 18),
                        label: Text(s.systemMode),
                      ),
                    ],
                    selected: {currentMode},
                    onSelectionChanged: (selected) {
                      context.read<ThemeCubit>().setMode(selected.first);
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      textStyle: WidgetStateProperty.all(
                        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Divider ──
                Divider(color: cs.outlineVariant, height: 1),
                const SizedBox(height: 16),

                // ── Theme color selector (list style) ──
                Text(s.theme, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 10),
                ...AppThemeType.values.map((type) {
                  final isSelected = currentType == type;
                  final colors = AppTheme.gradientOf(type);
                  final primary = AppTheme.primaryOf(type);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => context.read<ThemeCubit>().setTheme(type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? primary : cs.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                          color: isSelected
                              ? primary.withValues(alpha: 0.06)
                              : cs.surfaceContainerLow,
                        ),
                        child: Row(
                          children: [
                            // Gradient strip
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: colors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(AppTheme.emojiOf(type),
                                    style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Theme name
                            Expanded(
                              child: Text(
                                AppTheme.nameOf(type),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? primary : cs.onSurface,
                                ),
                              ),
                            ),
                            // Checkmark
                            if (isSelected)
                              Icon(Icons.check_circle, size: 22, color: primary)
                            else
                              Icon(Icons.circle_outlined, size: 22, color: cs.outlineVariant),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

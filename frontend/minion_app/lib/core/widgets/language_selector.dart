import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/language_cubit.dart';

/// Language selector widget.
/// [expanded] = true  → large pill button with popup (login page)
/// [expanded] = false → compact pill button with popup (header)
class LanguageSelector extends StatelessWidget {
  final bool expanded;
  const LanguageSelector({super.key, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (ctx, locale) {
        if (expanded) return _ExpandedSelector(locale: locale);
        return _CompactSelector(locale: locale);
      },
    );
  }
}

// ─── Shared popup menu builder ────────────────────────────────────────────────
List<PopupMenuEntry<String>> _buildMenuItems(
    BuildContext context, Locale locale) {
  return LanguageCubit.supportedLocales
      .map(
        (l) => PopupMenuItem<String>(
          value: l.code,
          child: Row(
            children: [
              Text(l.flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(l.name,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              if (l.code == locale.languageCode)
                Icon(Icons.check_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      )
      .toList();
}

// ─── Compact: small pill in header ────────────────────────────────────────────
class _CompactSelector extends StatelessWidget {
  final Locale locale;
  const _CompactSelector({required this.locale});

  @override
  Widget build(BuildContext context) {
    final current = LanguageCubit.supportedLocales.firstWhere(
      (l) => l.code == locale.languageCode,
      orElse: () => LanguageCubit.supportedLocales.first,
    );

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => _buildMenuItems(context, locale),
      onSelected: (code) =>
          context.read<LanguageCubit>().setLocale(Locale(code)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 5),
            Text(
              current.code.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ─── Expanded: larger pill on login page ──────────────────────────────────────
class _ExpandedSelector extends StatelessWidget {
  final Locale locale;
  const _ExpandedSelector({required this.locale});

  @override
  Widget build(BuildContext context) {
    final current = LanguageCubit.supportedLocales.firstWhere(
      (l) => l.code == locale.languageCode,
      orElse: () => LanguageCubit.supportedLocales.first,
    );
    final primary = Theme.of(context).colorScheme.primary;

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => _buildMenuItems(context, locale),
      onSelected: (code) =>
          context.read<LanguageCubit>().setLocale(Locale(code)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.07),
          border: Border.all(color: primary, width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              current.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: primary),
          ],
        ),
      ),
    );
  }
}

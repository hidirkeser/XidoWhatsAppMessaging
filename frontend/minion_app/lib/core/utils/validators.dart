import '../../l10n/generated/app_localizations.dart';

class Validators {
  static String? required(AppL10n s, String? value) {
    if (value == null || value.trim().isEmpty) return s.fieldRequired;
    return null;
  }

  static String? email(AppL10n s, String? value) {
    if (value == null || value.trim().isEmpty) return s.fieldRequired;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return s.invalidEmail;
    return null;
  }

  static String? optionalEmail(AppL10n s, String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return s.invalidEmail;
    return null;
  }

  static String? phone(AppL10n s, String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final phoneRegex = RegExp(r'^\+?[\d\s-]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) return s.invalidPhone;
    return null;
  }

  static String? personnummer(AppL10n s, String? value) {
    if (value == null || value.trim().isEmpty) return s.fieldRequired;
    final pnrRegex = RegExp(r'^\d{8,12}$');
    if (!pnrRegex.hasMatch(value.replaceAll('-', '').trim())) return s.invalidPersonnummer;
    return null;
  }

  static String? minLength(AppL10n s, String? value, int min) {
    if (value == null || value.trim().isEmpty) return s.fieldRequired;
    if (value.trim().length < min) return s.minLength(min);
    return null;
  }

  static String? positiveNumber(AppL10n s, String? value) {
    if (value == null || value.trim().isEmpty) return s.fieldRequired;
    final num = int.tryParse(value);
    if (num == null || num <= 0) return s.amountMustBePositive;
    return null;
  }
}

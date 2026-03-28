import 'package:flutter/material.dart';

enum AppThemeType { amberSunrise, roseGoldPremium }

class AppTheme {
  // ── Amber Sunrise palette ──────────────────────────────────────────────────
  static const Color amberPrimary   = Color(0xFFD97706);
  static const Color amberSecondary = Color(0xFFF59E0B);
  static const Color amberDark      = Color(0xFF92400E);
  static const Color amberBg        = Color(0xFFFFFBF0);
  static const List<Color> amberGradient = [
    Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFFBBF24),
  ];

  // ── Rose Gold Premium palette ──────────────────────────────────────────────
  static const Color rosePrimary   = Color(0xFFBE185D);
  static const Color roseSecondary = Color(0xFFEC4899);
  static const Color roseDark      = Color(0xFF831843);
  static const Color roseBg        = Color(0xFFFFF9FB);
  static const List<Color> roseGradient = [
    Color(0xFF831843), Color(0xFFBE185D), Color(0xFFEC4899),
  ];

  // ── Theme metadata ─────────────────────────────────────────────────────────
  static String nameOf(AppThemeType t) =>
      t == AppThemeType.amberSunrise ? 'Amber Sunrise' : 'Rose Gold Premium';

  static String emojiOf(AppThemeType t) =>
      t == AppThemeType.amberSunrise ? '🌅' : '💎';

  static List<Color> gradientOf(AppThemeType t) =>
      t == AppThemeType.amberSunrise ? amberGradient : roseGradient;

  static Color primaryOf(AppThemeType t) =>
      t == AppThemeType.amberSunrise ? amberPrimary : rosePrimary;

  static Color darkOf(AppThemeType t) =>
      t == AppThemeType.amberSunrise ? amberDark : roseDark;

  static Color bgOf(AppThemeType t) =>
      t == AppThemeType.amberSunrise ? amberBg : roseBg;

  // ── Build ThemeData ────────────────────────────────────────────────────────
  static ThemeData getTheme(AppThemeType type) {
    final seed = primaryOf(type);
    final bg   = bgOf(type);
    final cs   = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ).copyWith(surface: bg, surfaceContainerLowest: bg);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Legacy getter — kept for backward compatibility
  static ThemeData get lightTheme => getTheme(AppThemeType.roseGoldPremium);
}

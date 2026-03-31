import 'package:flutter/material.dart';

enum AppThemeType {
  amberSunrise,
  roseGoldPremium,
  oceanDeep,
  forestSage,
  midnightViolet,
}

enum AppThemeMode {
  light,
  dark,
  system,
}

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

  // ── Ocean Deep palette ─────────────────────────────────────────────────────
  static const Color oceanPrimary   = Color(0xFF0369A1);
  static const Color oceanSecondary = Color(0xFF0EA5E9);
  static const Color oceanDark      = Color(0xFF0C4A6E);
  static const Color oceanBg        = Color(0xFFF0F9FF);
  static const List<Color> oceanGradient = [
    Color(0xFF0C4A6E), Color(0xFF0369A1), Color(0xFF0EA5E9),
  ];

  // ── Forest Sage palette ────────────────────────────────────────────────────
  static const Color forestPrimary   = Color(0xFF15803D);
  static const Color forestSecondary = Color(0xFF22C55E);
  static const Color forestDark      = Color(0xFF14532D);
  static const Color forestBg        = Color(0xFFF5FAF7);
  static const List<Color> forestGradient = [
    Color(0xFF14532D), Color(0xFF15803D), Color(0xFF22C55E),
  ];

  // ── Midnight Violet palette ────────────────────────────────────────────────
  static const Color violetPrimary   = Color(0xFF7C3AED);
  static const Color violetSecondary = Color(0xFFA78BFA);
  static const Color violetDark      = Color(0xFF3B0764);
  static const Color violetBg        = Color(0xFFFAF5FF);
  static const List<Color> violetGradient = [
    Color(0xFF3B0764), Color(0xFF7C3AED), Color(0xFFA78BFA),
  ];

  // ── Dark mode common colors ────────────────────────────────────────────────
  static const Color darkScaffold = Color(0xFF121212);
  static const Color darkSurface  = Color(0xFF1E1E1E);
  static const Color darkCard     = Color(0xFF252525);

  // ── Theme metadata ─────────────────────────────────────────────────────────
  static String nameOf(AppThemeType t) => switch (t) {
    AppThemeType.amberSunrise    => 'Amber Sunrise',
    AppThemeType.roseGoldPremium => 'Rose Gold Premium',
    AppThemeType.oceanDeep       => 'Ocean Deep',
    AppThemeType.forestSage      => 'Forest Sage',
    AppThemeType.midnightViolet  => 'Midnight Violet',
  };

  static String emojiOf(AppThemeType t) => switch (t) {
    AppThemeType.amberSunrise    => '🌅',
    AppThemeType.roseGoldPremium => '💎',
    AppThemeType.oceanDeep       => '🌊',
    AppThemeType.forestSage      => '🌿',
    AppThemeType.midnightViolet  => '🔮',
  };

  static List<Color> gradientOf(AppThemeType t) => switch (t) {
    AppThemeType.amberSunrise    => amberGradient,
    AppThemeType.roseGoldPremium => roseGradient,
    AppThemeType.oceanDeep       => oceanGradient,
    AppThemeType.forestSage      => forestGradient,
    AppThemeType.midnightViolet  => violetGradient,
  };

  static Color primaryOf(AppThemeType t) => switch (t) {
    AppThemeType.amberSunrise    => amberPrimary,
    AppThemeType.roseGoldPremium => rosePrimary,
    AppThemeType.oceanDeep       => oceanPrimary,
    AppThemeType.forestSage      => forestPrimary,
    AppThemeType.midnightViolet  => violetPrimary,
  };

  static Color darkOf(AppThemeType t) => switch (t) {
    AppThemeType.amberSunrise    => amberDark,
    AppThemeType.roseGoldPremium => roseDark,
    AppThemeType.oceanDeep       => oceanDark,
    AppThemeType.forestSage      => forestDark,
    AppThemeType.midnightViolet  => violetDark,
  };

  static Color bgOf(AppThemeType t) => switch (t) {
    AppThemeType.amberSunrise    => amberBg,
    AppThemeType.roseGoldPremium => roseBg,
    AppThemeType.oceanDeep       => oceanBg,
    AppThemeType.forestSage      => forestBg,
    AppThemeType.midnightViolet  => violetBg,
  };

  static String modeIconLabel(AppThemeMode mode) => switch (mode) {
    AppThemeMode.light  => '☀️',
    AppThemeMode.dark   => '🌙',
    AppThemeMode.system => '📱',
  };

  static ThemeMode toFlutterThemeMode(AppThemeMode mode) => switch (mode) {
    AppThemeMode.light  => ThemeMode.light,
    AppThemeMode.dark   => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };

  // ── Build Light ThemeData ──────────────────────────────────────────────────
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
        color: cs.surface,
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
        fillColor: cs.surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
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

  // ── Build Dark ThemeData ───────────────────────────────────────────────────
  static ThemeData getDarkTheme(AppThemeType type) {
    final seed = primaryOf(type);
    final cs = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).copyWith(
      surface: darkSurface,
      surfaceContainerLowest: darkScaffold,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: darkScaffold,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: darkScaffold,
        surfaceTintColor: Colors.transparent,
        foregroundColor: cs.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkCard,
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
        fillColor: darkCard,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
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

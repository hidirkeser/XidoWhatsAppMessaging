import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeState extends Equatable {
  final AppThemeType type;
  final AppThemeMode mode;

  const ThemeState({
    this.type = AppThemeType.roseGoldPremium,
    this.mode = AppThemeMode.system,
  });

  ThemeState copyWith({AppThemeType? type, AppThemeMode? mode}) {
    return ThemeState(
      type: type ?? this.type,
      mode: mode ?? this.mode,
    );
  }

  @override
  List<Object?> get props => [type, mode];
}

class ThemeCubit extends Cubit<ThemeState> {
  static const _themeKey = 'app_theme';
  static const _modeKey = 'app_theme_mode';

  ThemeCubit() : super(const ThemeState());

  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString(_themeKey);
    final themeMatch = AppThemeType.values.where((t) => t.name == savedTheme);
    final type = themeMatch.isNotEmpty ? themeMatch.first : AppThemeType.roseGoldPremium;

    final savedMode = prefs.getString(_modeKey);
    final modeMatch = AppThemeMode.values.where((m) => m.name == savedMode);
    final mode = modeMatch.isNotEmpty ? modeMatch.first : AppThemeMode.system;

    emit(ThemeState(type: type, mode: mode));
  }

  Future<void> setTheme(AppThemeType theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.name);
    emit(state.copyWith(type: theme));
  }

  Future<void> setMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
    emit(state.copyWith(mode: mode));
  }

  Future<void> toggleMode() async {
    final nextMode = switch (state.mode) {
      AppThemeMode.light  => AppThemeMode.dark,
      AppThemeMode.dark   => AppThemeMode.light,
      AppThemeMode.system => AppThemeMode.dark,
    };
    await setMode(nextMode);
  }
}

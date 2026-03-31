import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeCubit extends Cubit<AppThemeType> {
  static const _key = 'app_theme';

  // Default: Rose Gold Premium (Theme 3)
  ThemeCubit() : super(AppThemeType.roseGoldPremium);

  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    final match = AppThemeType.values.where((t) => t.name == saved);
    emit(match.isNotEmpty ? match.first : AppThemeType.roseGoldPremium);
  }

  Future<void> setTheme(AppThemeType theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, theme.name);
    emit(theme);
  }
}

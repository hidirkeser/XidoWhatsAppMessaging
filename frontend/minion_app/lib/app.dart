import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/cubit/language_cubit.dart';
import 'core/cubit/theme_cubit.dart';
import 'core/di/injection_container.dart';
import 'core/network/api_client.dart';
import 'core/routing/app_router.dart';
import 'core/services/fcm_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/credits/cubit/credit_cubit.dart';
import 'features/profile/cubit/avatar_cubit.dart';
import 'l10n/generated/app_localizations.dart';

class _AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  void update(bool value) {
    if (_isAuthenticated != value) {
      _isAuthenticated = value;
      notifyListeners();
    }
  }
}

class MinionApp extends StatefulWidget {
  const MinionApp({super.key});

  @override
  State<MinionApp> createState() => _MinionAppState();
}

class _MinionAppState extends State<MinionApp> {
  late final _AuthNotifier _authNotifier;
  late final RouterConfig<Object> _router;

  @override
  void initState() {
    super.initState();
    _authNotifier = _AuthNotifier();
    _router = AppRouter.buildRouter(_authNotifier);
  }

  @override
  void dispose() {
    _authNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LanguageCubit()..loadSavedLocale(),
        ),
        BlocProvider(
          create: (_) => ThemeCubit()..loadSavedTheme(),
        ),
        BlocProvider(
          create: (_) => AvatarCubit()..loadAvatar(),
        ),
        BlocProvider(
          create: (_) => CreditCubit(),
        ),
        BlocProvider(
          create: (_) =>
              AuthBloc(apiClient: sl<ApiClient>())..add(AuthCheckStatus()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          _authNotifier.update(state is AuthAuthenticated);
          // Authenticated olunca bakiye + FCM token yükle
          if (state is AuthAuthenticated) {
            context.read<CreditCubit>().loadBalance();
            FcmNotificationService.instance.initialize();
          }
        },
        child: BlocBuilder<ThemeCubit, AppThemeType>(
          builder: (context, themeType) {
            return BlocBuilder<LanguageCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp.router(
                  title: 'Minion',
                  theme: AppTheme.getTheme(themeType),
                  routerConfig: _router,
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: AppL10n.localizationsDelegates,
                  supportedLocales: AppL10n.supportedLocales,
                  locale: locale,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

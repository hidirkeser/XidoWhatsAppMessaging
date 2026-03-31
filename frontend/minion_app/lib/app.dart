import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/cubit/language_cubit.dart';
import 'core/cubit/notification_cubit.dart';
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
  bool _hasGdprConsent = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get hasGdprConsent => _hasGdprConsent;

  void update(bool authenticated, bool hasConsent) {
    if (_isAuthenticated != authenticated || _hasGdprConsent != hasConsent) {
      _isAuthenticated = authenticated;
      _hasGdprConsent = hasConsent;
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
          create: (_) => NotificationCubit(sl<ApiClient>()),
        ),
        BlocProvider(
          create: (_) =>
              AuthBloc(apiClient: sl<ApiClient>())..add(AuthCheckStatus()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          _authNotifier.update(
            state is AuthAuthenticated,
            state is AuthAuthenticated && state.gdprConsentAcceptedAt != null,
          );
          // Authenticated olunca bakiye + FCM token yükle
          if (state is AuthAuthenticated) {
            context.read<CreditCubit>().loadBalance();
            context.read<NotificationCubit>().fetchUnreadCount();
            FcmNotificationService.instance.initialize();
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<LanguageCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp.router(
                  title: 'Minion',
                  theme: AppTheme.getTheme(themeState.type),
                  darkTheme: AppTheme.getDarkTheme(themeState.type),
                  themeMode: AppTheme.toFlutterThemeMode(themeState.mode),
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

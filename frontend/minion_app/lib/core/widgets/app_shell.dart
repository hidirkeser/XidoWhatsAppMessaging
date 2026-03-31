import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/cubit/avatar_cubit.dart';
import '../cubit/notification_cubit.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cubit/theme_cubit.dart';
import '../theme/app_theme.dart';
import '../services/fcm_notification_service.dart';
import 'breadcrumb_bar.dart';
import 'language_selector.dart';
import 'minion_logo.dart';

// ─── User menu values ─────────────────────────────────────────────────────────
enum _UserMenuAction { profile, admin, logout }

class AppShell extends StatefulWidget {
  final Widget child;
  final String location;

  const AppShell({super.key, required this.child, required this.location});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  StreamSubscription<String>? _navSub;
  StreamSubscription<RemoteMessage>? _fgSub;

  @override
  void initState() {
    super.initState();

    // ── FCM: navigate on notification tap ──────────────────────────────────
    _navSub = FcmNotificationService.navigationStream.listen((route) {
      if (mounted) context.push(route);
    });

    // ── FCM: foreground message → in-app SnackBar + badge increment ────────
    _fgSub = FcmNotificationService.foregroundStream.listen((message) {
      if (!mounted) return;
      context.read<NotificationCubit>().increment();
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';
      final type = message.data['type'] as String? ?? '';
      final refId = message.data['referenceId'] as String? ?? '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 5),
          content: Row(
            children: [
              Icon(
                _iconForType(type),
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title.isNotEmpty)
                      Text(title,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    if (body.isNotEmpty)
                      Text(body,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.8))),
                  ],
                ),
              ),
            ],
          ),
          action: SnackBarAction(
                  label: 'Görüntüle',
                  onPressed: () {
                    if (type == 'DelegationGranted') {
                      context.go('/delegations');
                    } else if (refId.isNotEmpty) {
                      context.push('/delegations/$refId');
                    } else {
                      context.go('/notifications');
                    }
                  },
                ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navSub?.cancel();
    _fgSub?.cancel();
    super.dispose();
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'DelegationGranted'       => Icons.assignment_ind,
      'DelegationAccepted'      => Icons.check_circle_outline,
      'DelegationRejected'      => Icons.cancel_outlined,
      'DelegationRevoked'       => Icons.block,
      'DelegationExpiringSoon'  => Icons.timer_outlined,
      'DelegationExpired'       => Icons.timer_off_outlined,
      'LowCreditWarning'        => Icons.account_balance_wallet_outlined,
      'CreditPurchaseSuccess'   => Icons.payments_outlined,
      _                         => Icons.notifications_outlined,
    };
  }

  static const _tabRoutes = ['/home', '/delegations', '/notifications', '/profile'];

  bool get _showBottomNav =>
      widget.location == '/home' ||
      widget.location == '/delegations' ||
      widget.location == '/notifications' ||
      widget.location == '/profile';

  int get _tabIndex {
    if (widget.location.startsWith('/delegations')) return 1;
    if (widget.location.startsWith('/notifications')) return 2;
    if (widget.location.startsWith('/profile')) return 3;
    return 0;
  }

  List<BreadcrumbItem> _breadcrumbs(AppL10n s) {
    final loc = widget.location;
    final home = BreadcrumbItem(label: s.dashboard, route: '/home');

    if (loc == '/home') return [BreadcrumbItem(label: s.dashboard)];
    if (loc == '/delegations') return [home, BreadcrumbItem(label: s.delegations)];
    if (loc == '/delegations/create') {
      return [home, BreadcrumbItem(label: s.delegations, route: '/delegations'), BreadcrumbItem(label: s.grantDelegation)];
    }
    if (loc.startsWith('/delegations/')) {
      return [home, BreadcrumbItem(label: s.delegations, route: '/delegations'), BreadcrumbItem(label: s.delegationDetail)];
    }
    if (loc == '/notifications') return [home, BreadcrumbItem(label: s.notifications)];
    if (loc == '/profile') return [home, BreadcrumbItem(label: s.profile)];
    if (loc == '/credits/purchase') return [home, BreadcrumbItem(label: s.purchaseCredits)];
    if (loc == '/credits/history') return [home, BreadcrumbItem(label: s.creditHistory)];
    if (loc == '/admin') return [home, BreadcrumbItem(label: s.adminPanel)];
    if (loc == '/admin/organizations') {
      return [home, BreadcrumbItem(label: s.adminPanel, route: '/admin'), BreadcrumbItem(label: s.organizationManagement)];
    }
    if (loc == '/admin/credit-packages') {
      return [home, BreadcrumbItem(label: s.adminPanel, route: '/admin'), BreadcrumbItem(label: s.creditPackageManagement)];
    }
    if (loc == '/admin/audit-logs') {
      return [home, BreadcrumbItem(label: s.adminPanel, route: '/admin'), BreadcrumbItem(label: s.auditLog)];
    }
    return [home];
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated && authState.isAdmin;
    final authUser = authState is AuthAuthenticated ? authState : null;
    final avatarPath = context.watch<AvatarCubit>().state;
    final breadcrumbs = _breadcrumbs(s);
    final isHome = widget.location == '/home';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 34),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Top bar ──
                SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    children: [
                      const SizedBox(width: 12),

                      // ── Logo → taps to home ──
                      GestureDetector(
                        onTap: isHome ? null : () => context.go('/home'),
                        child: Row(
                          children: [
                            const MinionLogo(size: 34),
                            const SizedBox(width: 8),
                            Text(
                              'Minion',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ── Dark mode toggle ──
                      BlocBuilder<ThemeCubit, ThemeState>(
                        builder: (context, themeState) {
                          final isDark = themeState.mode == AppThemeMode.dark ||
                              (themeState.mode == AppThemeMode.system &&
                                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);
                          return IconButton(
                            tooltip: isDark ? s.lightMode : s.darkMode,
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) =>
                                  RotationTransition(turns: animation, child: child),
                              child: Icon(
                                isDark ? Icons.light_mode : Icons.dark_mode,
                                key: ValueKey(isDark),
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            onPressed: () => context.read<ThemeCubit>().toggleMode(),
                          );
                        },
                      ),

                      // ── Language selector (popup) ──
                      const LanguageSelector(),
                      const SizedBox(width: 4),

                      // ── User menu (name + admin + logout) ──
                      PopupMenuButton<_UserMenuAction>(
                        tooltip: '',
                        offset: const Offset(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (_) => [
                          // ── User name header (tap → profile) ──
                          PopupMenuItem<_UserMenuAction>(
                            value: _UserMenuAction.profile,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: Text(
                                    authUser != null &&
                                            authUser.firstName.isNotEmpty
                                        ? authUser.firstName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      authUser != null
                                          ? '${authUser.firstName} ${authUser.lastName}'
                                          : '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (authUser != null)
                                      Text(
                                        authUser.personalNumber,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          // ── Admin Panel (admin only) ──
                          if (isAdmin)
                            PopupMenuItem<_UserMenuAction>(
                              value: _UserMenuAction.admin,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings_outlined,
                                    size: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    s.adminPanel,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // ── Logout ──
                          PopupMenuItem<_UserMenuAction>(
                            value: _UserMenuAction.logout,
                            child: Row(
                              children: [
                                Icon(Icons.logout,
                                    size: 18, color: Colors.red[600]),
                                const SizedBox(width: 10),
                                Text(
                                  s.logout,
                                  style: TextStyle(color: Colors.red[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (action) {
                          if (action == _UserMenuAction.profile) {
                            context.go('/profile');
                          } else if (action == _UserMenuAction.admin) {
                            context.push('/admin');
                          } else if (action == _UserMenuAction.logout) {
                            context.read<AuthBloc>().add(AuthLogout());
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                backgroundImage: avatarPath != null &&
                                        !kIsWeb &&
                                        File(avatarPath).existsSync()
                                    ? FileImage(File(avatarPath))
                                    : null,
                                child: avatarPath == null
                                    ? Text(
                                        authUser != null &&
                                                authUser.firstName.isNotEmpty
                                            ? authUser.firstName[0]
                                                .toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                // ── Breadcrumb ──
                BreadcrumbBar(items: breadcrumbs),
              ],
            ),
          ),
        ),
      ),
      body: widget.child,
      bottomNavigationBar: _showBottomNav
          ? BlocBuilder<NotificationCubit, int>(
              builder: (context, unreadCount) => NavigationBar(
                selectedIndex: _tabIndex,
                onDestinationSelected: (i) => context.go(_tabRoutes[i]),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.dashboard_outlined),
                    selectedIcon: const Icon(Icons.dashboard),
                    label: s.dashboard,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.assignment_outlined),
                    selectedIcon: const Icon(Icons.assignment),
                    label: s.delegations,
                  ),
                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                      child: const Icon(Icons.notifications_outlined),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                      child: const Icon(Icons.notifications),
                    ),
                    label: s.notifications,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person),
                    label: s.profile,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/cubit/avatar_cubit.dart';
import '../../l10n/generated/app_localizations.dart';
import 'breadcrumb_bar.dart';
import 'language_selector.dart';
import 'minion_logo.dart';

// ─── User menu values ─────────────────────────────────────────────────────────
enum _UserMenuAction { profile, admin, logout }

class AppShell extends StatelessWidget {
  final Widget child;
  final String location;

  const AppShell({super.key, required this.child, required this.location});

  static const _tabRoutes = ['/home', '/delegations', '/notifications', '/profile'];

  bool get _showBottomNav =>
      location == '/home' ||
      location == '/delegations' ||
      location == '/notifications' ||
      location == '/profile';

  int get _tabIndex {
    if (location.startsWith('/delegations')) return 1;
    if (location.startsWith('/notifications')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  List<BreadcrumbItem> _breadcrumbs(AppL10n s) {
    final home = BreadcrumbItem(label: s.dashboard, route: '/home');

    if (location == '/home') return [BreadcrumbItem(label: s.dashboard)];
    if (location == '/delegations') return [home, BreadcrumbItem(label: s.delegations)];
    if (location == '/delegations/create') {
      return [home, BreadcrumbItem(label: s.delegations, route: '/delegations'), BreadcrumbItem(label: s.grantDelegation)];
    }
    if (location.startsWith('/delegations/')) {
      return [home, BreadcrumbItem(label: s.delegations, route: '/delegations'), BreadcrumbItem(label: s.delegationDetail)];
    }
    if (location == '/notifications') return [home, BreadcrumbItem(label: s.notifications)];
    if (location == '/profile') return [home, BreadcrumbItem(label: s.profile)];
    if (location == '/credits/purchase') return [home, BreadcrumbItem(label: s.purchaseCredits)];
    if (location == '/credits/history') return [home, BreadcrumbItem(label: s.creditHistory)];
    if (location == '/admin') return [home, BreadcrumbItem(label: s.adminPanel)];
    if (location == '/admin/organizations') {
      return [home, BreadcrumbItem(label: s.adminPanel, route: '/admin'), BreadcrumbItem(label: s.organizationManagement)];
    }
    if (location == '/admin/credit-packages') {
      return [home, BreadcrumbItem(label: s.adminPanel, route: '/admin'), BreadcrumbItem(label: s.creditPackageManagement)];
    }
    if (location == '/admin/audit-logs') {
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
    final isHome = location == '/home';

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
      body: child,
      bottomNavigationBar: _showBottomNav
          ? NavigationBar(
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
                  icon: const Icon(Icons.notifications_outlined),
                  selectedIcon: const Icon(Icons.notifications),
                  label: s.notifications,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: s.profile,
                ),
              ],
            )
          : null,
    );
  }
}

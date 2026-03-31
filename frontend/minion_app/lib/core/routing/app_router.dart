import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/audit_log_page.dart';
import '../../features/admin/presentation/pages/manage_credit_packages_page.dart';
import '../../features/admin/presentation/pages/manage_organizations_page.dart';
import '../../features/admin/presentation/pages/manage_products_page.dart';
import '../../features/admin/presentation/pages/manage_corporate_applications_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/products/presentation/pages/purchase_subscription_page.dart';
import '../../features/corporate/presentation/pages/corporate_apply_page.dart';
import '../../features/auth/presentation/pages/gdpr_consent_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/credits/presentation/pages/credit_history_page.dart';
import '../../features/credits/presentation/pages/purchase_credits_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/delegations/presentation/pages/create_delegation_page.dart';
import '../../features/delegations/presentation/pages/delegation_detail_page.dart';
import '../../features/delegations/presentation/pages/delegations_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/notifications/presentation/pages/notification_preferences_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/verification/presentation/pages/verification_page.dart';
import '../widgets/app_shell.dart';

class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>();
  static final _shellKey = GlobalKey<NavigatorState>();

  /// Build the router ONCE. Auth changes are communicated via [authNotifier]
  /// so GoRouter re-evaluates its redirect without recreating the router.
  static GoRouter buildRouter(ChangeNotifier authNotifier) {
    return GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/login',
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final notifier = authNotifier as dynamic;
        final isAuthenticated = notifier.isAuthenticated as bool;
        final hasConsent = notifier.hasGdprConsent as bool;
        final loc = state.matchedLocation;

        if (!isAuthenticated && loc != '/login' && !loc.startsWith('/verify/')) return '/login';
        if (isAuthenticated && loc == '/login') {
          return hasConsent ? '/home' : '/consent';
        }
        if (isAuthenticated && !hasConsent && loc != '/consent') return '/consent';
        if (isAuthenticated && hasConsent && loc == '/consent') return '/home';
        return null;
      },
      routes: [
        // ── Public ──────────────────────────────────────────────────────────
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/consent', builder: (_, __) => const GdprConsentPage()),
        GoRoute(
          path: '/verify/:code',
          builder: (_, state) => VerificationPage(
            code: state.pathParameters['code']!,
          ),
        ),

        // ── Authenticated shell (persistent header + footer) ─────────────
        ShellRoute(
          navigatorKey: _shellKey,
          builder: (context, state, child) => AppShell(
            location: state.matchedLocation,
            child: child,
          ),
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const DashboardPage()),
            GoRoute(path: '/delegations', builder: (_, __) => const DelegationsPage()),
            GoRoute(path: '/delegations/create', builder: (_, __) => const CreateDelegationPage()),
            GoRoute(
              path: '/delegations/:id',
              builder: (_, state) => DelegationDetailPage(
                delegationId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
            GoRoute(path: '/notifications/preferences', builder: (_, __) => const NotificationPreferencesPage()),
            GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
            GoRoute(path: '/credits/purchase', builder: (_, __) => const PurchaseCreditsPage()),
            GoRoute(path: '/credits/history', builder: (_, __) => const CreditHistoryPage()),
            GoRoute(path: '/products', builder: (_, __) => const ProductsPage()),
            GoRoute(
              path: '/subscriptions/purchase/:productId',
              builder: (_, state) => PurchaseSubscriptionPage(
                productId: state.pathParameters['productId']!,
              ),
            ),
            GoRoute(path: '/corporate/apply', builder: (_, __) => const CorporateApplyPage()),
            GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardPage()),
            GoRoute(path: '/admin/organizations', builder: (_, __) => const ManageOrganizationsPage()),
            GoRoute(path: '/admin/credit-packages', builder: (_, __) => const ManageCreditPackagesPage()),
            GoRoute(path: '/admin/products', builder: (_, __) => const ManageProductsPage()),
            GoRoute(path: '/admin/corporate-applications', builder: (_, __) => const ManageCorporateApplicationsPage()),
            GoRoute(path: '/admin/audit-logs', builder: (_, __) => const AuditLogPage()),
          ],
        ),
      ],
    );
  }
}

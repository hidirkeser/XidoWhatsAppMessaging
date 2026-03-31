import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static const String _devUrl     = 'http://localhost:5131/api';
  static const String _prodUrl    = 'https://minion-api-production.up.railway.app/api';
  static const String _stagingUrl = 'https://minion-api-staging.up.railway.app/api';

  // Override via --dart-define=API_URL=https://... at build time
  static const String _override = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    return kReleaseMode ? _prodUrl : _devUrl;
  }

  static String get stagingUrl => _stagingUrl;

  // Auth
  static const String authInit = '/auth/init';
  static const String authCollect = '/auth/collect';
  static const String authCancel = '/auth/cancel';
  static const String authRefresh = '/auth/refresh';
  static const String authSignInit = '/auth/sign/init';
  static const String authSignCollect = '/auth/sign/collect';
  static String authQr(String orderRef) => '/auth/qr/$orderRef';

  // Users
  static const String usersMe = '/users/me';
  static const String usersSearch = '/users/search';
  static const String usersDeviceToken = '/users/device-token';
  static const String usersMyOrgs = '/users/me/organizations';

  // Delegations
  static const String delegations = '/delegations';
  static const String delegationsGranted = '/delegations/granted';
  static const String delegationsReceived = '/delegations/received';
  static String delegationById(String id) => '/delegations/$id';
  static String delegationAccept(String id) => '/delegations/$id/accept';
  static String delegationReject(String id) => '/delegations/$id/reject';
  static String delegationRevoke(String id) => '/delegations/$id/revoke';
  static String verifyDelegation(String code) => '/verify/$code';
  static String verifyDelegationInit(String code) => '/verify/$code/init';
  static String verifyDelegationCollect(String code) => '/verify/$code/collect';

  // Credits
  static String get creditsBase => '$baseUrl/credits';
  static const String creditsBalance = '/credits/balance';
  static const String creditsHistory = '/credits/history';
  static const String creditsPackages = '/credits/packages';
  static const String creditsPurchase = '/credits/purchase';

  // Products
  static const String products = '/products';
  static String productById(String id) => '/products/$id';

  // Subscriptions
  static const String subscriptionsCurrent = '/subscriptions/current';
  static const String subscriptionsQuota = '/subscriptions/quota';
  static const String subscriptionsPurchase = '/subscriptions/purchase';

  // Corporate Applications
  static const String corporateApply = '/corporate/apply';
  static const String adminCorporateApplications = '/admin/corporate/applications';
  static String adminCorporateApprove(String id) => '/admin/corporate/applications/$id/approve';
  static String adminCorporateReject(String id) => '/admin/corporate/applications/$id/reject';

  // Admin Products
  static const String adminProducts = '/admin/products';
  static String adminProductById(String id) => '/admin/products/$id';
  static String adminProductToggle(String id) => '/admin/products/$id/toggle';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static String notificationById(String id) => '/notifications/$id';

  // Users - notification preferences
  static const String notificationPreferences = '/users/me/notification-preferences';
}

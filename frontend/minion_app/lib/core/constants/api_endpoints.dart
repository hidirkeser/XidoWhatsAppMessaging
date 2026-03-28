class ApiEndpoints {
  static const String baseUrl = 'http://localhost:5131/api';

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

  // Credits
  static const String creditsBase = '$baseUrl/credits';
  static const String creditsBalance = '/credits/balance';
  static const String creditsHistory = '/credits/history';
  static const String creditsPackages = '/credits/packages';
  static const String creditsPurchase = '/credits/purchase';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
}

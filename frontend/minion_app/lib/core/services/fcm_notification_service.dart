import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import '../di/injection_container.dart';
import '../network/api_client.dart';

/// Background message handler — must be a top-level function (not a method).
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // Background messages are auto-displayed by the OS.
  // We don't need to do anything here for delegation notifications.
  debugPrint('[FCM-BG] Message received: ${message.data}');
}

/// Centralized Firebase Cloud Messaging service.
///
/// Responsibilities:
///   1. Request notification permissions (iOS)
///   2. Get & register FCM token with backend
///   3. Refresh token when it changes
///   4. Handle foreground messages (show in-app banner)
///   5. Handle notification tap (navigate to delegation detail)
///
/// Setup:
///   1. Create a Firebase project at https://console.firebase.google.com
///   2. Run: flutterfire configure --project=YOUR_PROJECT_ID
///      → generates lib/firebase_options.dart
///   3. For iOS: upload APNs certificate/key in Firebase Console
///      → Project Settings → Cloud Messaging → iOS app → APNs
class FcmNotificationService {
  FcmNotificationService._();

  static final _instance = FcmNotificationService._();
  static FcmNotificationService get instance => _instance;

  /// Stream that emits a route string when a notification tap should navigate.
  /// Listen in AppShell or a root widget to handle navigation.
  static final _navigationStream = StreamController<String>.broadcast();
  static Stream<String> get navigationStream => _navigationStream.stream;

  /// Emitted when a foreground message arrives (title, body).
  static final _foregroundStream =
      StreamController<RemoteMessage>.broadcast();
  static Stream<RemoteMessage> get foregroundStream =>
      _foregroundStream.stream;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final messaging = FirebaseMessaging.instance;

      // ── 1. Request permissions (required on iOS) ────────────────────────
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

      // If permission is denied/blocked, skip the rest silently
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[FCM] Permission denied — skipping FCM setup.');
        return;
      }

      // ── 2. Register background handler ──────────────────────────────────
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

      // ── 3. Get & register token ──────────────────────────────────────────
      try {
        final token = await messaging.getToken();
        if (token != null) await _registerToken(token);
        // ── 4. Refresh token ───────────────────────────────────────────────
        messaging.onTokenRefresh.listen(_registerToken);
      } catch (e) {
        debugPrint('[FCM] Token fetch failed (web/VAPID?): $e');
      }

      // ── 5. Foreground messages ───────────────────────────────────────────
      FirebaseMessaging.onMessage.listen((msg) {
        debugPrint('[FCM-FG] ${msg.notification?.title}: ${msg.notification?.body}');
        _foregroundStream.add(msg);
      });

      // ── 6. Background notification tap ──────────────────────────────────
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // ── 7. App launched from terminated state via notification ───────────
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) _handleNotificationTap(initialMessage);

      debugPrint('[FCM] Service initialized.');
    } catch (e) {
      debugPrint('[FCM] Initialization failed (non-fatal): $e');
    }
  }

  /// Registers the FCM token with the Minion backend.
  static Future<void> _registerToken(String token) async {
    try {
      final platform = defaultTargetPlatform == TargetPlatform.iOS
          ? 'iOS'
          : defaultTargetPlatform == TargetPlatform.android
              ? 'Android'
              : 'Web';

      await sl<ApiClient>().dio.post(
        ApiEndpoints.usersDeviceToken,
        data: {'token': token, 'platform': platform},
      );
      debugPrint('[FCM] Token registered with backend (platform: $platform)');
    } on DioException catch (e) {
      // Might fail if user is not authenticated yet — will retry on next login
      debugPrint('[FCM] Token registration skipped: ${e.message}');
    }
  }

  /// Handles tap on a notification (background or terminated state).
  static void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'] as String?;
    final referenceId = message.data['referenceId'] as String?;

    debugPrint('[FCM] Notification tapped. type=$type referenceId=$referenceId');

    switch (type) {
      case 'DelegationGranted':
        // Navigate to list so delegate can accept/reject
        _navigationStream.add('/delegations');
        break;
      case 'DelegationAccepted':
      case 'DelegationRejected':
      case 'DelegationRevoked':
      case 'DelegationExpiringSoon':
      case 'DelegationExpired':
        if (referenceId != null && referenceId.isNotEmpty) {
          _navigationStream.add('/delegations/$referenceId');
        } else {
          _navigationStream.add('/delegations');
        }
        break;
      case 'CreditPurchaseSuccess':
        _navigationStream.add('/credits/history');
        break;
      default:
        _navigationStream.add('/notifications');
    }
  }

  void dispose() {
    _navigationStream.close();
    _foregroundStream.close();
  }
}

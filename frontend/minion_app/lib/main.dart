import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injection_container.dart';
import 'firebase_options.dart';

// ─── Firebase FCM — Activation Checklist ─────────────────────────────────────
// 1. Create Firebase project: https://console.firebase.google.com
// 2. Install FlutterFire CLI:
//      dart pub global activate flutterfire_cli
// 3. Configure (generates real firebase_options.dart):
//      flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
// 4. iOS only — Upload APNs key in Firebase Console:
//      Project Settings → Cloud Messaging → Apple app → APNs Authentication Key
// 5. Android only — Place google-services.json in android/app/ then
//      uncomment the google-services plugin lines in settings.gradle.kts
//      and android/app/build.gradle.kts
// 6. iOS only — Uncomment FirebaseApp.configure() in ios/Runner/AppDelegate.swift
// 7. Uncomment Firebase.initializeApp() below and FcmNotificationService.initialize()
//    in lib/app.dart
// ─────────────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // STEP 7: Uncomment after completing the checklist above
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  await initDependencies();
  runApp(const MinionApp());
}

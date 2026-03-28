import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injection_container.dart';

// FIREBASE SETUP (one-time):
// 1. Install FlutterFire CLI:  dart pub global activate flutterfire_cli
// 2. Run:  flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
//    → Creates lib/firebase_options.dart automatically
// 3. Uncomment the import below and the Firebase.initializeApp() call
// 4. For iOS: add APNs key in Firebase Console → Project Settings → Cloud Messaging

// import 'firebase_options.dart';  // ← uncomment after running flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (uncomment after running flutterfire configure)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  await initDependencies();
  runApp(const MinionApp());
}

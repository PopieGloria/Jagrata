import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase configuration for Web platform
/// 
/// SETUP INSTRUCTIONS:
/// 1. Copy this file to 'firebase_options_web.dart'
/// 2. Replace all placeholder values with your actual Firebase web configuration
/// 3. Get your config from Firebase Console > Project Settings > General > Web apps
class DefaultFirebaseOptionsWeb {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
    measurementId: 'YOUR_MEASUREMENT_ID',
  );
} 
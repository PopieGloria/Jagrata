import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase configuration for iOS platform
/// 
/// SETUP INSTRUCTIONS:
/// 1. Copy this file to 'firebase_options_ios.dart'
/// 2. Replace all placeholder values with your actual Firebase iOS configuration
/// 3. Get your config from Firebase Console > Project Settings > General > iOS apps
class DefaultFirebaseOptionsIOS {
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_BUNDLE_ID',
  );
} 
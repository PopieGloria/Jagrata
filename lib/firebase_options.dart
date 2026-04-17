// File generated based on Firebase config in web/index.html.
// Re-run `flutterfire configure` to update this file for all platforms.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBV5ynEzbvYowI_dhU9ogyprL4oD-5ywWI',
    appId: '1:265788001372:web:c64d2d972d195ac125aa99',
    messagingSenderId: '265788001372',
    projectId: 'jagrata-420',
    authDomain: 'jagrata-420.firebaseapp.com',
    storageBucket: 'jagrata-420.firebasestorage.app',
    measurementId: 'G-Z6Y1ESFFLR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBV5ynEzbvYowI_dhU9ogyprL4oD-5ywWI',
    appId: '1:265788001372:web:c64d2d972d195ac125aa99',
    messagingSenderId: '265788001372',
    projectId: 'jagrata-420',
    storageBucket: 'jagrata-420.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBV5ynEzbvYowI_dhU9ogyprL4oD-5ywWI',
    appId: '1:265788001372:web:c64d2d972d195ac125aa99',
    messagingSenderId: '265788001372',
    projectId: 'jagrata-420',
    storageBucket: 'jagrata-420.firebasestorage.app',
    iosBundleId: 'com.nav.jagrata',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBV5ynEzbvYowI_dhU9ogyprL4oD-5ywWI',
    appId: '1:265788001372:web:c64d2d972d195ac125aa99',
    messagingSenderId: '265788001372',
    projectId: 'jagrata-420',
    storageBucket: 'jagrata-420.firebasestorage.app',
    iosBundleId: 'com.nav.jagrata',
  );
}

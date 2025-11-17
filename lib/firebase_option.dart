// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web',
      );
    }

    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDy3abZ46_svsLEBvI7Sd00fS2GdGVGwBU',
    appId: '1:882892153396:android:bfe92e5c3dbbdad769e061',
    messagingSenderId: '882892153396',
    projectId: 'cloudgallery123-872f0',
    storageBucket: 'cloudgallery123-872f0.firebasestorage.app',
  );
}

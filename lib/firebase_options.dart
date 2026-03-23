// Generated manually from android/app/google-services.json.
// For Web: add a Web app in Firebase Console (Project settings) and replace [web]'s
// `appId` with the value from the Firebase config snippet if Auth/Firebase rejects
// the Android app id. Or run: flutterfire configure (requires Firebase CLI + login).
//
// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        // Desktop/iOS: not registered in this project yet; Android options use the same project.
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDBUqDkth-eqTNT1BCgS4mkigTc6OZ0Rrc',
    appId: '1:682374337728:android:cb8bb1e1ea04f37c08c925',
    messagingSenderId: '682374337728',
    projectId: 'mosques-250bd',
    storageBucket: 'mosques-250bd.firebasestorage.app',
  );

  /// Web requires explicit options (no google-services on web).
  /// `appId` should ideally be the Web app id (`1:...:web:...`) from Firebase Console.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDBUqDkth-eqTNT1BCgS4mkigTc6OZ0Rrc',
    appId: '1:682374337728:android:cb8bb1e1ea04f37c08c925',
    messagingSenderId: '682374337728',
    projectId: 'mosques-250bd',
    authDomain: 'mosques-250bd.firebaseapp.com',
    storageBucket: 'mosques-250bd.firebasestorage.app',
  );
}

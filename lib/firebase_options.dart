// File generated to mirror `flutterfire configure` output.
// Values taken from android/app/google-services.json (project: mini-shop-f8b3c).
// Do NOT edit by hand for production multi-platform apps — re-run
// `flutterfire configure` if you later add iOS / Web / macOS.
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        're-run the FlutterFire CLI to add web support.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for Android in this lab. '
          'Re-run the FlutterFire CLI to add ${defaultTargetPlatform.name}.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBSSIlvNv1LD-t4LqI-hwNb3H8I_B0OQk4',
    appId: '1:673847018023:android:9adcf9f1bfb6b70aaf8402',
    messagingSenderId: '673847018023',
    projectId: 'mini-shop-f8b3c',
    storageBucket: 'mini-shop-f8b3c.firebasestorage.app',
  );
}

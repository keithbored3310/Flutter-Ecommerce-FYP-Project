// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgFpqSuaVjrcjoBbeTgXCBFKGhRBU6gds',
    appId: '1:765453277308:android:a00633ba237c185414d1f9',
    messagingSenderId: '765453277308',
    projectId: 'ecommerce-cb642',
    databaseURL: 'https://ecommerce-cb642-default-rtdb.firebaseio.com',
    storageBucket: 'ecommerce-cb642.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAGWd6C1zknG69eTvTXHQf_5GO4CtVK9Tc',
    appId: '1:765453277308:ios:5a04138d87ba85cc14d1f9',
    messagingSenderId: '765453277308',
    projectId: 'ecommerce-cb642',
    databaseURL: 'https://ecommerce-cb642-default-rtdb.firebaseio.com',
    storageBucket: 'ecommerce-cb642.appspot.com',
    iosClientId: '765453277308-49jc32b9v8kvr5o59qsq0d2vjinjk1sb.apps.googleusercontent.com',
    iosBundleId: 'com.example.ecommerce',
  );
}

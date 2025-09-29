import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCj_AaUK__9Zvm3PXl9hXfsMduK3g_BOSs',
    appId: '1:572728091032:web:65d6e4c345fc0af90c0bed',
    messagingSenderId: '572728091032',
    projectId: 'micro-commerce-6de78',
    authDomain: 'micro-commerce-6de78.firebaseapp.com',
    storageBucket: 'micro-commerce-6de78.firebasestorage.app',
    measurementId: 'G-YMD73JK0JF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCj_AaUK__9Zvm3PXl9hXfsMduK3g_BOSs',
    appId: '1:572728091032:android:demo',
    messagingSenderId: '572728091032',
    projectId: 'micro-commerce-6de78',
    storageBucket: 'micro-commerce-6de78.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCj_AaUK__9Zvm3PXl9hXfsMduK3g_BOSs',
    appId: '1:572728091032:ios:demo',
    messagingSenderId: '572728091032',
    projectId: 'micro-commerce-6de78',
    storageBucket: 'micro-commerce-6de78.firebasestorage.app',
    iosBundleId: 'com.example.microCommerce',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCj_AaUK__9Zvm3PXl9hXfsMduK3g_BOSs',
    appId: '1:572728091032:macos:demo',
    messagingSenderId: '572728091032',
    projectId: 'micro-commerce-6de78',
    storageBucket: 'micro-commerce-6de78.firebasestorage.app',
    iosBundleId: 'com.example.microCommerce',
  );
}
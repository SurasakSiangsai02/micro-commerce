import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'config/app_config.dart';

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

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: AppConfig.firebaseApiKey ?? '',
    appId: AppConfig.firebaseAppIdWeb ?? '',
    messagingSenderId: AppConfig.firebaseMessagingSenderId ?? '',
    projectId: AppConfig.firebaseProjectId ?? '',
    authDomain: AppConfig.firebaseAuthDomain ?? '',
    storageBucket: AppConfig.firebaseStorageBucket ?? '',
    measurementId: AppConfig.firebaseMeasurementId ?? '',
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: AppConfig.firebaseApiKey ?? '',
    appId: AppConfig.firebaseAppIdAndroid ?? '',
    messagingSenderId: AppConfig.firebaseMessagingSenderId ?? '',
    projectId: AppConfig.firebaseProjectId ?? '',
    storageBucket: AppConfig.firebaseStorageBucket ?? '',
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: AppConfig.firebaseApiKey ?? '',
    appId: AppConfig.firebaseAppIdIos ?? '',
    messagingSenderId: AppConfig.firebaseMessagingSenderId ?? '',
    projectId: AppConfig.firebaseProjectId ?? '',
    storageBucket: AppConfig.firebaseStorageBucket ?? '',
    iosBundleId: AppConfig.firebaseIosBundleId ?? '',
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: AppConfig.firebaseApiKey ?? '',
    appId: AppConfig.firebaseAppIdMacos ?? '',
    messagingSenderId: AppConfig.firebaseMessagingSenderId ?? '',
    projectId: AppConfig.firebaseProjectId ?? '',
    storageBucket: AppConfig.firebaseStorageBucket ?? '',
    iosBundleId: AppConfig.firebaseIosBundleId ?? '',
  );
}
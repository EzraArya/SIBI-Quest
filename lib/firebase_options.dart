import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Placeholder Firebase options generated for the project.
///
/// Replace the placeholder values by running `flutterfire configure` once the
/// Firebase project is ready. Keeping this file in source control allows the
/// rest of the codebase to compile while configuration is pending.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase is not configured for Web.');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAydAqWJ7rK2p_wZSDrB4XrXeY3Dk933Dw',
    appId: '1:680633038491:android:cffc1eea89d33bb2c1783e',
    messagingSenderId: '680633038491',
    projectId: 'sign-quest-3da19',
    storageBucket: 'sign-quest-3da19.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDr1VmIqfg-2nPYljP9GeH2m5B5CLJYk8M',
    appId: '1:680633038491:ios:1605bed11448e7a9c1783e',
    messagingSenderId: '680633038491',
    projectId: 'sign-quest-3da19',
    storageBucket: 'sign-quest-3da19.firebasestorage.app',
    iosBundleId: 'com.example.sibiQuest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'TODO-MACOS-API-KEY',
    appId: 'TODO-MACOS-APP-ID',
    messagingSenderId: 'TODO-MACOS-SENDER-ID',
    projectId: 'TODO-PROJECT-ID',
    storageBucket: 'TODO-MACOS-STORAGE-BUCKET',
    iosBundleId: 'com.example.sibi_quest',
  );
}

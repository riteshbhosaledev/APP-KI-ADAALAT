import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for the Nyaay Dhrishti application
class FirebaseConfig {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyA1MJ_Aa7ve_yK_diKfrvVHaIhSoT_b6Nc",
    appId: "1:478866771246:android:b8814bfe5fb13405babebf",
    messagingSenderId: "478866771246",
    projectId: "nyaay-dhrishti",
    storageBucket: "nyaay-dhrishti.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyA1MJ_Aa7ve_yK_diKfrvVHaIhSoT_b6Nc",
    appId: "1:478866771246:ios:b8814bfe5fb13405babebf",
    messagingSenderId: "478866771246",
    projectId: "nyaay-dhrishti",
    storageBucket: "nyaay-dhrishti.firebasestorage.app",
    iosBundleId: "com.example.nyaayDhrishti",
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyA1MJ_Aa7ve_yK_diKfrvVHaIhSoT_b6Nc",
    appId: "1:478866771246:web:b8814bfe5fb13405babebf",
    messagingSenderId: "478866771246",
    projectId: "nyaay-dhrishti",
    storageBucket: "nyaay-dhrishti.firebasestorage.app",
  );

  /// Get Firebase options for current platform
  static FirebaseOptions get currentPlatform {
    // This will be replaced with proper platform detection in production
    return android;
  }
}

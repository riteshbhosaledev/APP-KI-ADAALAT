import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';

/// Utility class for Firebase emulator setup and management
class EmulatorUtils {
  /// Default emulator ports
  static const int firestorePort = 8080;
  static const int authPort = 9099;
  static const int storagePort = 9199;
  static const String emulatorHost = 'localhost';

  /// Check if running in emulator mode
  static bool get isEmulatorMode => FirebaseService().isEmulatorMode;

  /// Initialize Firebase with emulator for development
  static Future<void> initializeWithEmulator() async {
    if (kDebugMode) {
      debugPrint('Initializing Firebase with emulator...');
      await FirebaseService().initialize(useEmulator: true);
    } else {
      debugPrint('Emulator mode not available in release builds');
      await FirebaseService().initialize(useEmulator: false);
    }
  }

  /// Get emulator connection info
  static Map<String, dynamic> getEmulatorInfo() {
    return {
      'host': emulatorHost,
      'ports': {
        'firestore': firestorePort,
        'auth': authPort,
        'storage': storagePort,
      },
      'isActive': isEmulatorMode,
    };
  }

  /// Print emulator status
  static void printEmulatorStatus() {
    if (kDebugMode) {
      final info = getEmulatorInfo();
      debugPrint('=== Firebase Emulator Status ===');
      debugPrint('Active: ${info['isActive']}');
      debugPrint('Host: ${info['host']}');
      debugPrint('Firestore Port: ${info['ports']['firestore']}');
      debugPrint('Auth Port: ${info['ports']['auth']}');
      debugPrint('Storage Port: ${info['ports']['storage']}');
      debugPrint('===============================');
    }
  }
}

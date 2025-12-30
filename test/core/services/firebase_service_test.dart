import 'package:flutter_test/flutter_test.dart';
import 'package:nyaay_dhrishti/core/services/firebase_service.dart';
import 'package:nyaay_dhrishti/core/services/app_initialization_service.dart';

void main() {
  group('Firebase Service Tests', () {
    test('Firebase service should initialize correctly', () async {
      final firebaseService = FirebaseService();

      // Initially not initialized
      expect(firebaseService.isInitialized, false);
      expect(firebaseService.isEmulatorMode, false);
    });

    test('App initialization service should provide status', () async {
      final appInitService = AppInitializationService();

      final status = appInitService.getInitializationStatus();

      expect(status, isA<Map<String, dynamic>>());
      expect(status.containsKey('isInitialized'), true);
      expect(status.containsKey('firebase'), true);
      expect(status.containsKey('emulatorMode'), true);
    });
  });
}

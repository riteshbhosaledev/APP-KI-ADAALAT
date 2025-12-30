import 'package:flutter_test/flutter_test.dart';
import 'package:nyaay_dhrishti/core/services/app_initialization_service.dart';
import 'package:nyaay_dhrishti/core/services/firebase_service.dart';
import 'package:nyaay_dhrishti/core/services/connection_service.dart';
import 'package:nyaay_dhrishti/core/services/sync_service.dart';

void main() {
  group('Firebase Integration Tests', () {
    test('All services should initialize correctly', () async {
      // Test that services can be instantiated without errors
      final appInitService = AppInitializationService();
      final firebaseService = FirebaseService();
      final connectionService = ConnectionService();
      final syncService = SyncService();

      // Verify initial states
      expect(appInitService.isInitialized, false);
      expect(firebaseService.isInitialized, false);
      expect(firebaseService.isEmulatorMode, false);

      // Verify services are singletons
      expect(AppInitializationService(), same(appInitService));
      expect(FirebaseService(), same(firebaseService));
      expect(ConnectionService(), same(connectionService));
      expect(SyncService(), same(syncService));
    });

    test('Initialization status should be comprehensive', () {
      final appInitService = AppInitializationService();
      final status = appInitService.getInitializationStatus();

      // Verify all required status fields are present
      expect(status.containsKey('isInitialized'), true);
      expect(status.containsKey('error'), true);
      expect(status.containsKey('firebase'), true);
      expect(status.containsKey('emulatorMode'), true);
      expect(status.containsKey('connectionStatus'), true);
      expect(status.containsKey('syncStatus'), true);

      // Verify sync status is detailed
      final syncStatus = status['syncStatus'] as Map<String, dynamic>;
      expect(syncStatus.containsKey('isSyncing'), true);
      expect(syncStatus.containsKey('lastSyncTime'), true);
      expect(syncStatus.containsKey('pendingOperations'), true);
      expect(syncStatus.containsKey('canSync'), true);
      expect(syncStatus.containsKey('isOnline'), true);
      expect(syncStatus.containsKey('isFirebaseConnected'), true);
    });

    test('Sync service should manage pending operations', () {
      final syncService = SyncService();

      // Initially no pending operations
      expect(syncService.pendingOperations, isEmpty);

      // Add pending operation
      syncService.addPendingOperation('test-operation-1');
      expect(syncService.pendingOperations, contains('test-operation-1'));
      expect(syncService.pendingOperations.length, 1);

      // Add another operation
      syncService.addPendingOperation('test-operation-2');
      expect(syncService.pendingOperations.length, 2);

      // Remove operation
      syncService.removePendingOperation('test-operation-1');
      expect(
        syncService.pendingOperations,
        isNot(contains('test-operation-1')),
      );
      expect(syncService.pendingOperations, contains('test-operation-2'));
      expect(syncService.pendingOperations.length, 1);

      // Remove remaining operation
      syncService.removePendingOperation('test-operation-2');
      expect(syncService.pendingOperations, isEmpty);
    });

    test('Connection service should provide connectivity status', () {
      final connectionService = ConnectionService();

      // Should have default values
      expect(connectionService.isOnline, isA<bool>());
      expect(connectionService.isFirebaseConnected, isA<bool>());
      expect(connectionService.canSyncData, isA<bool>());

      // canSyncData should be logical AND of online and firebase connected
      final expectedCanSync =
          connectionService.isOnline && connectionService.isFirebaseConnected;
      expect(connectionService.canSyncData, expectedCanSync);
    });
  });
}

import 'package:flutter/foundation.dart';
import 'firebase_service.dart';
import 'connection_service.dart';
import 'sync_service.dart';

/// Service to handle app initialization and coordinate all core services
class AppInitializationService {
  static final AppInitializationService _instance =
      AppInitializationService._internal();
  factory AppInitializationService() => _instance;
  AppInitializationService._internal();

  bool _isInitialized = false;
  String? _initializationError;

  bool get isInitialized => _isInitialized;
  String? get initializationError => _initializationError;

  /// Initialize all core services
  Future<void> initialize({bool useEmulator = false}) async {
    if (_isInitialized) return;

    try {
      debugPrint('Starting app initialization...');

      // Step 1: Initialize Firebase
      debugPrint('Initializing Firebase...');
      await FirebaseService().initialize(useEmulator: useEmulator);

      // Step 2: Initialize connection monitoring
      debugPrint('Initializing connection service...');
      await ConnectionService().initialize();

      // Step 3: Initialize sync service
      debugPrint('Initializing sync service...');
      await SyncService().initialize();

      _isInitialized = true;
      _initializationError = null;

      debugPrint('App initialization completed successfully');
    } catch (e) {
      _initializationError = e.toString();
      debugPrint('App initialization failed: $e');
      rethrow;
    }
  }

  /// Get initialization status
  Map<String, dynamic> getInitializationStatus() {
    return {
      'isInitialized': _isInitialized,
      'error': _initializationError,
      'firebase': FirebaseService().isInitialized,
      'emulatorMode': FirebaseService().isEmulatorMode,
      'connectionStatus': ConnectionService().isOnline,
      'syncStatus': SyncService().getSyncStatus(),
    };
  }

  /// Reinitialize services (useful for error recovery)
  Future<void> reinitialize({bool useEmulator = false}) async {
    _isInitialized = false;
    _initializationError = null;
    await initialize(useEmulator: useEmulator);
  }
}

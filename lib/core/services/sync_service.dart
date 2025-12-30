import 'dart:async';
import 'package:flutter/foundation.dart';
import 'connection_service.dart';
import 'firebase_service.dart';

/// Service to handle data synchronization between offline and online states
class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ConnectionService _connectionService = ConnectionService();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  final List<String> _pendingOperations = [];

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  List<String> get pendingOperations => List.unmodifiable(_pendingOperations);

  StreamSubscription? _connectionSubscription;

  /// Initialize sync service
  Future<void> initialize() async {
    // Listen to connection changes
    _connectionService.addListener(_onConnectionChanged);

    // Initial sync if online
    if (_connectionService.canSyncData) {
      await _performSync();
    }
  }

  /// Handle connection state changes
  void _onConnectionChanged() {
    if (_connectionService.canSyncData && !_isSyncing) {
      _performSync();
    }
  }

  /// Perform data synchronization
  Future<void> _performSync() async {
    if (_isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      debugPrint('Starting data synchronization...');

      // Wait for pending writes to complete
      await _firebaseService.firestore.waitForPendingWrites();

      // Clear any pending operations that completed
      _pendingOperations.clear();

      _lastSyncTime = DateTime.now();
      debugPrint('Data synchronization completed successfully');
    } catch (e) {
      debugPrint('Error during synchronization: $e');
      // Add failed operations to pending list
      _pendingOperations.add(
        'sync_failed_${DateTime.now().millisecondsSinceEpoch}',
      );
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Force sync data
  Future<void> forceSync() async {
    if (_connectionService.canSyncData) {
      await _performSync();
    } else {
      throw Exception('Cannot sync: No network connection');
    }
  }

  /// Add operation to pending queue
  void addPendingOperation(String operationId) {
    _pendingOperations.add(operationId);
    notifyListeners();
  }

  /// Remove operation from pending queue
  void removePendingOperation(String operationId) {
    _pendingOperations.remove(operationId);
    notifyListeners();
  }

  /// Get sync status information
  Map<String, dynamic> getSyncStatus() {
    return {
      'isSyncing': _isSyncing,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'pendingOperations': _pendingOperations.length,
      'canSync': _connectionService.canSyncData,
      'isOnline': _connectionService.isOnline,
      'isFirebaseConnected': _connectionService.isFirebaseConnected,
    };
  }

  /// Check if data is up to date
  bool get isDataUpToDate {
    if (!_connectionService.canSyncData) return false;
    if (_pendingOperations.isNotEmpty) return false;
    if (_lastSyncTime == null) return false;

    // Consider data up to date if synced within last 5 minutes
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
    return _lastSyncTime!.isAfter(fiveMinutesAgo);
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}

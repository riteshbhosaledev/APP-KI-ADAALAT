import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service to manage network connectivity and Firebase connection state
class ConnectionService extends ChangeNotifier {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isOnline = true;
  bool _isFirebaseConnected = true;

  bool get isOnline => _isOnline;
  bool get isFirebaseConnected => _isFirebaseConnected;
  bool get canSyncData => _isOnline && _isFirebaseConnected;

  /// Initialize connection monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );

    // Monitor Firebase connection state
    _monitorFirebaseConnection();
  }

  /// Update connection status based on connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );

    if (wasOnline != _isOnline) {
      notifyListeners();
      if (_isOnline) {
        _handleConnectionRestored();
      } else {
        _handleConnectionLost();
      }
    }
  }

  /// Monitor Firebase Firestore connection state
  void _monitorFirebaseConnection() {
    FirebaseFirestore.instance
        .enableNetwork()
        .then((_) {
          _isFirebaseConnected = true;
          notifyListeners();
        })
        .catchError((error) {
          _isFirebaseConnected = false;
          notifyListeners();
        });
  }

  /// Handle connection restored
  void _handleConnectionRestored() {
    debugPrint('Connection restored - enabling Firebase network');
    FirebaseFirestore.instance.enableNetwork().then((_) {
      _isFirebaseConnected = true;
      notifyListeners();
    });
  }

  /// Handle connection lost
  void _handleConnectionLost() {
    debugPrint('Connection lost - Firebase will work offline');
    _isFirebaseConnected = false;
    notifyListeners();
  }

  /// Force refresh connection state
  Future<void> refreshConnectionState() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

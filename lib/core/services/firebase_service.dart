import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../config/firebase_config.dart';

/// Service to manage Firebase initialization and configuration
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isInitialized = false;
  bool _isEmulatorMode = false;

  bool get isInitialized => _isInitialized;
  bool get isEmulatorMode => _isEmulatorMode;

  /// Initialize Firebase with proper configuration
  Future<void> initialize({bool useEmulator = false}) async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase
      await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);

      // Configure Firestore
      await _configureFirestore(useEmulator);

      // Configure Auth
      await _configureAuth(useEmulator);

      // Configure Storage
      await _configureStorage(useEmulator);

      _isInitialized = true;
      _isEmulatorMode = useEmulator;

      debugPrint('Firebase initialized successfully (Emulator: $useEmulator)');
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Configure Firestore with offline support
  Future<void> _configureFirestore(bool useEmulator) async {
    final firestore = FirebaseFirestore.instance;

    if (useEmulator) {
      // Connect to Firestore emulator
      firestore.useFirestoreEmulator('localhost', 8080);
      debugPrint('Connected to Firestore emulator');
    }

    // Configure cache settings with offline persistence
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    debugPrint('Firestore configured with offline support');
  }

  /// Configure Firebase Auth
  Future<void> _configureAuth(bool useEmulator) async {
    if (useEmulator) {
      // Connect to Auth emulator
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      debugPrint('Connected to Auth emulator');
    }
  }

  /// Configure Firebase Storage
  Future<void> _configureStorage(bool useEmulator) async {
    if (useEmulator) {
      // Connect to Storage emulator
      await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
      debugPrint('Connected to Storage emulator');
    }
  }

  /// Get Firestore instance
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Get Auth instance
  FirebaseAuth get auth => FirebaseAuth.instance;

  /// Get Storage instance
  FirebaseStorage get storage => FirebaseStorage.instance;

  /// Check if Firebase is properly connected
  Future<bool> checkConnection() async {
    try {
      // Try to read from Firestore to test connection
      await firestore.collection('_connection_test').limit(1).get();
      return true;
    } catch (e) {
      debugPrint('Firebase connection check failed: $e');
      return false;
    }
  }

  /// Enable offline mode
  Future<void> enableOfflineMode() async {
    try {
      await firestore.disableNetwork();
      debugPrint('Firebase offline mode enabled');
    } catch (e) {
      debugPrint('Error enabling offline mode: $e');
    }
  }

  /// Enable online mode
  Future<void> enableOnlineMode() async {
    try {
      await firestore.enableNetwork();
      debugPrint('Firebase online mode enabled');
    } catch (e) {
      debugPrint('Error enabling online mode: $e');
    }
  }

  /// Clear offline cache
  Future<void> clearOfflineCache() async {
    try {
      await firestore.clearPersistence();
      debugPrint('Firebase offline cache cleared');
    } catch (e) {
      debugPrint('Error clearing offline cache: $e');
    }
  }
}

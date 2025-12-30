import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user_models.dart';
import 'auth_service.dart';

/// Service for managing user session persistence across app restarts
class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final AuthService _authService = AuthService();

  // Session storage keys
  static const String _sessionKey = 'user_session';
  static const String _lastLoginKey = 'last_login';
  static const String _rememberMeKey = 'remember_me';
  static const String _userPreferencesKey = 'user_preferences';

  /// Initialize session service
  Future<void> initialize() async {
    try {
      await _restoreSession();
    } catch (e) {
      debugPrint('Error initializing session service: $e');
    }
  }

  /// Save current session data
  Future<void> saveSession({bool rememberMe = false}) async {
    try {
      if (_authService.currentUser != null &&
          _authService.currentUserProfile != null) {
        final sessionData = {
          'userId': _authService.currentUserId,
          'email': _authService.currentUserEmail,
          'displayName': _authService.currentUserDisplayName,
          'role': _authService.currentUserProfile!.role.toFirestore(),
          'lastLogin': DateTime.now().millisecondsSinceEpoch,
          'rememberMe': rememberMe,
        };

        await _saveToSecureStorage(_sessionKey, jsonEncode(sessionData));
        await _saveToSecureStorage(
          _lastLoginKey,
          DateTime.now().millisecondsSinceEpoch.toString(),
        );
        await _saveToSecureStorage(_rememberMeKey, rememberMe.toString());

        debugPrint('Session saved successfully');
      }
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  /// Restore session from storage
  Future<void> _restoreSession() async {
    try {
      final sessionData = await _getFromSecureStorage(_sessionKey);
      final rememberMe = await _getFromSecureStorage(_rememberMeKey);

      if (sessionData != null && rememberMe == 'true') {
        final session = jsonDecode(sessionData);
        final lastLogin = DateTime.fromMillisecondsSinceEpoch(
          session['lastLogin'],
        );

        // Check if session is still valid (e.g., within 30 days)
        if (DateTime.now().difference(lastLogin).inDays <= 30) {
          // Session is valid, Firebase Auth should handle automatic sign-in
          // if the user's authentication token is still valid
          debugPrint('Valid session found, attempting to restore');

          // Wait for auth state to be restored by Firebase
          await Future.delayed(const Duration(milliseconds: 500));

          if (_authService.isSignedIn) {
            debugPrint('Session restored successfully');
          } else {
            // Clear invalid session
            await clearSession();
          }
        } else {
          // Session expired
          await clearSession();
          debugPrint('Session expired, cleared');
        }
      }
    } catch (e) {
      debugPrint('Error restoring session: $e');
      await clearSession();
    }
  }

  /// Clear session data
  Future<void> clearSession() async {
    try {
      await _removeFromSecureStorage(_sessionKey);
      await _removeFromSecureStorage(_lastLoginKey);
      await _removeFromSecureStorage(_rememberMeKey);
      await _removeFromSecureStorage(_userPreferencesKey);

      debugPrint('Session cleared');
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  /// Save user preferences
  Future<void> saveUserPreferences(NotificationPreferences preferences) async {
    try {
      await _saveToSecureStorage(
        _userPreferencesKey,
        jsonEncode(preferences.toFirestore()),
      );
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
    }
  }

  /// Get saved user preferences
  Future<NotificationPreferences?> getUserPreferences() async {
    try {
      final preferencesData = await _getFromSecureStorage(_userPreferencesKey);
      if (preferencesData != null) {
        final data = jsonDecode(preferencesData);
        return NotificationPreferences.fromFirestore(data);
      }
    } catch (e) {
      debugPrint('Error getting user preferences: $e');
    }
    return null;
  }

  /// Check if user has an active session
  Future<bool> hasActiveSession() async {
    try {
      final sessionData = await _getFromSecureStorage(_sessionKey);
      final rememberMe = await _getFromSecureStorage(_rememberMeKey);

      if (sessionData != null && rememberMe == 'true') {
        final session = jsonDecode(sessionData);
        final lastLogin = DateTime.fromMillisecondsSinceEpoch(
          session['lastLogin'],
        );

        // Check if session is still valid
        return DateTime.now().difference(lastLogin).inDays <= 30;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking active session: $e');
      return false;
    }
  }

  /// Get last login time
  Future<DateTime?> getLastLoginTime() async {
    try {
      final lastLoginData = await _getFromSecureStorage(_lastLoginKey);
      if (lastLoginData != null) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(lastLoginData));
      }
    } catch (e) {
      debugPrint('Error getting last login time: $e');
    }
    return null;
  }

  /// Check if remember me is enabled
  Future<bool> isRememberMeEnabled() async {
    try {
      final rememberMe = await _getFromSecureStorage(_rememberMeKey);
      return rememberMe == 'true';
    } catch (e) {
      debugPrint('Error checking remember me: $e');
      return false;
    }
  }

  /// Update session activity
  Future<void> updateSessionActivity() async {
    try {
      if (_authService.isSignedIn) {
        await _saveToSecureStorage(
          _lastLoginKey,
          DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }
    } catch (e) {
      debugPrint('Error updating session activity: $e');
    }
  }

  /// Get session info for debugging
  Future<Map<String, dynamic>?> getSessionInfo() async {
    try {
      final sessionData = await _getFromSecureStorage(_sessionKey);
      if (sessionData != null) {
        return jsonDecode(sessionData);
      }
    } catch (e) {
      debugPrint('Error getting session info: $e');
    }
    return null;
  }

  // Platform-specific secure storage methods
  // Note: In a production app, you would use a package like flutter_secure_storage
  // For this implementation, we'll use a simple in-memory storage for demonstration

  static final Map<String, String> _storage = {};

  Future<void> _saveToSecureStorage(String key, String value) async {
    try {
      // In production, use flutter_secure_storage or similar
      _storage[key] = value;
    } catch (e) {
      debugPrint('Error saving to secure storage: $e');
    }
  }

  Future<String?> _getFromSecureStorage(String key) async {
    try {
      // In production, use flutter_secure_storage or similar
      return _storage[key];
    } catch (e) {
      debugPrint('Error getting from secure storage: $e');
      return null;
    }
  }

  Future<void> _removeFromSecureStorage(String key) async {
    try {
      // In production, use flutter_secure_storage or similar
      _storage.remove(key);
    } catch (e) {
      debugPrint('Error removing from secure storage: $e');
    }
  }

  /// Clear all stored data (for logout or account deletion)
  Future<void> clearAllStoredData() async {
    try {
      _storage.clear();
      debugPrint('All stored data cleared');
    } catch (e) {
      debugPrint('Error clearing all stored data: $e');
    }
  }

  /// Validate session integrity
  Future<bool> validateSessionIntegrity() async {
    try {
      final sessionData = await _getFromSecureStorage(_sessionKey);
      if (sessionData == null) return false;

      final session = jsonDecode(sessionData);
      final userId = session['userId'];

      // Check if the stored user ID matches the current Firebase user
      return userId == _authService.currentUserId;
    } catch (e) {
      debugPrint('Error validating session integrity: $e');
      return false;
    }
  }

  /// Handle session timeout
  Future<void> handleSessionTimeout() async {
    try {
      await clearSession();
      await _authService.signOut();
      debugPrint('Session timed out, user signed out');
    } catch (e) {
      debugPrint('Error handling session timeout: $e');
    }
  }
}

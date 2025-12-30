import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_models.dart';
import '../repositories/user_repository.dart';

/// Authentication service for managing user authentication and sessions
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  /// Current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user profile (cached)
  UserProfile? _currentUserProfile;
  UserProfile? get currentUserProfile => _currentUserProfile;

  /// Initialize authentication service
  Future<void> initialize() async {
    try {
      // Listen to auth state changes
      _auth.authStateChanges().listen(_onAuthStateChanged);

      // Load current user profile if authenticated
      if (currentUser != null) {
        await _loadCurrentUserProfile();
      }
    } catch (e) {
      debugPrint('Error initializing auth service: $e');
    }
  }

  /// Handle authentication state changes
  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      await _loadCurrentUserProfile();
      await _updateLastLogin();
    } else {
      _currentUserProfile = null;
    }
  }

  /// Load current user profile from Firestore
  Future<void> _loadCurrentUserProfile() async {
    try {
      if (currentUser != null) {
        _currentUserProfile = await _userRepository.getById(currentUser!.uid);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  /// Update last login time
  Future<void> _updateLastLogin() async {
    try {
      if (currentUser != null) {
        await _userRepository.updateLastLogin(currentUser!.uid);
      }
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify user profile exists and is active
      if (credential.user != null) {
        final userProfile = await _userRepository.getById(credential.user!.uid);
        if (userProfile == null) {
          await signOut();
          throw Exception('User profile not found');
        }
        if (!userProfile.isActive) {
          await signOut();
          throw Exception('User account is deactivated');
        }
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Create user account with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required UserProfile userProfile,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name in Firebase Auth
        await credential.user!.updateDisplayName(userProfile.displayName);

        // Create user profile in Firestore
        final profileWithId = userProfile.copyWith(
          userId: credential.user!.uid,
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _userRepository.createValidatedUser(profileWithId);

        // Set custom claims for role-based access
        await _setUserRole(credential.user!.uid, userProfile.role);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Account creation failed: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUserProfile = null;
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      if (currentUser == null) {
        throw Exception('No user signed in');
      }
      await currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      if (currentUser == null) {
        throw Exception('No user signed in');
      }

      // Update email in Firebase Auth
      await currentUser!.verifyBeforeUpdateEmail(newEmail);

      // Update email in user profile
      if (_currentUserProfile != null) {
        final updatedProfile = _currentUserProfile!.copyWith(
          email: newEmail,
          updatedAt: DateTime.now(),
        );
        await _userRepository.update(currentUser!.uid, updatedProfile);
        _currentUserProfile = updatedProfile;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Email update failed: $e');
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      if (currentUser == null) {
        throw Exception('No user signed in');
      }
      await currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Email verification failed: $e');
    }
  }

  /// Check if current user's email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Reload current user to get updated verification status
  Future<void> reloadUser() async {
    try {
      if (currentUser != null) {
        await currentUser!.reload();
      }
    } catch (e) {
      debugPrint('Error reloading user: $e');
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      if (currentUser == null) {
        throw Exception('No user signed in');
      }

      final userId = currentUser!.uid;

      // Delete user profile from Firestore
      await _userRepository.delete(userId);

      // Delete Firebase Auth user
      await currentUser!.delete();

      _currentUserProfile = null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }

  /// Reauthenticate user with password
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      if (currentUser == null || currentUser!.email == null) {
        throw Exception('No user signed in');
      }

      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );

      await currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Reauthentication failed: $e');
    }
  }

  /// Check if user has specific role
  bool hasRole(UserRole role) {
    return _currentUserProfile?.role == role;
  }

  /// Check if user is active
  bool get isUserActive => _currentUserProfile?.isActive ?? false;

  /// Get user role
  UserRole? get userRole => _currentUserProfile?.role;

  /// Refresh current user profile from Firestore
  Future<void> refreshUserProfile() async {
    await _loadCurrentUserProfile();
  }

  /// Set user role (for admin use - requires backend function)
  Future<void> _setUserRole(String userId, UserRole role) async {
    // Note: In a production app, this would typically be done through
    // a Cloud Function to set custom claims securely
    // For now, we'll just store the role in the user profile
    debugPrint('Setting user role: ${role.toFirestore()} for user: $userId');
  }

  /// Handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email address');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'email-already-in-use':
        return Exception('An account already exists with this email address');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'user-disabled':
        return Exception('This user account has been disabled');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed');
      case 'requires-recent-login':
        return Exception('Please sign in again to perform this action');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Get current user ID
  String? get currentUserId => currentUser?.uid;

  /// Get current user email
  String? get currentUserEmail => currentUser?.email;

  /// Get current user display name
  String? get currentUserDisplayName => currentUser?.displayName;
}

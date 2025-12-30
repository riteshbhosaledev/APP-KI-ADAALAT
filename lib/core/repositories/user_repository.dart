import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_models.dart';
import 'base_repository.dart';

/// Repository for managing user profiles in Firestore
class UserRepository extends BaseRepository<UserProfile> {
  @override
  String get collectionName => 'users';

  @override
  UserProfile fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserProfile.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(UserProfile item) {
    return item.toFirestore();
  }

  /// Get user by email
  Future<UserProfile?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await collection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user by email: $e');
    }
  }

  /// Get users by role
  Future<List<UserProfile>> getUsersByRole(UserRole role) async {
    try {
      final querySnapshot = await collection
          .where('role', isEqualTo: role.toFirestore())
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting users by role: $e');
    }
  }

  /// Stream users by role
  Stream<List<UserProfile>> streamUsersByRole(UserRole role) {
    return collection
        .where('role', isEqualTo: role.toFirestore())
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList(),
        );
  }

  /// Get lawyers by court
  Future<List<UserProfile>> getLawyersByCourt(String courtId) async {
    try {
      final querySnapshot = await collection
          .where('role', isEqualTo: UserRole.lawyer.toFirestore())
          .where('isActive', isEqualTo: true)
          .get();

      // Filter by court in practice areas or other criteria as needed
      return querySnapshot.docs
          .map((doc) => fromFirestore(doc))
          .where((user) => user.lawyerProfile != null)
          .toList();
    } catch (e) {
      throw Exception('Error getting lawyers by court: $e');
    }
  }

  /// Get judges by court
  Future<List<UserProfile>> getJudgesByCourt(String courtId) async {
    try {
      final querySnapshot = await collection
          .where('role', isEqualTo: UserRole.judge.toFirestore())
          .where('judgeProfile.courtId', isEqualTo: courtId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting judges by court: $e');
    }
  }

  /// Get court masters by court
  Future<List<UserProfile>> getCourtMastersByCourt(String courtId) async {
    try {
      final querySnapshot = await collection
          .where('role', isEqualTo: UserRole.courtMaster.toFirestore())
          .where('courtMasterProfile.courtId', isEqualTo: courtId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error getting court masters by court: $e');
    }
  }

  /// Update user stats
  Future<void> updateUserStats(String userId, UserStats stats) async {
    try {
      await updateFields(userId, {
        'stats': stats.toFirestore(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Error updating user stats: $e');
    }
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences(
    String userId,
    NotificationPreferences preferences,
  ) async {
    try {
      await updateFields(userId, {
        'notificationPreferences': preferences.toFirestore(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Error updating notification preferences: $e');
    }
  }

  /// Update profile image URL
  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await updateFields(userId, {
        'profileImageUrl': imageUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Error updating profile image: $e');
    }
  }

  /// Update last login time
  Future<void> updateLastLogin(String userId) async {
    try {
      final currentStats = await getById(userId);
      if (currentStats != null) {
        final updatedStats = currentStats.stats.copyWith(
          lastLoginAt: DateTime.now(),
        );
        await updateUserStats(userId, updatedStats);
      }
    } catch (e) {
      throw Exception('Error updating last login: $e');
    }
  }

  /// Deactivate user account
  Future<void> deactivateUser(String userId) async {
    try {
      await updateFields(userId, {
        'isActive': false,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Error deactivating user: $e');
    }
  }

  /// Reactivate user account
  Future<void> reactivateUser(String userId) async {
    try {
      await updateFields(userId, {
        'isActive': true,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Error reactivating user: $e');
    }
  }

  /// Search users by name or email
  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation that searches by display name prefix
      final querySnapshot = await collection
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .where('isActive', isEqualTo: true)
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }

  /// Validate user profile before saving
  bool validateUserProfile(UserProfile profile) {
    return profile.isValid();
  }

  /// Create user with validation
  Future<String> createValidatedUser(UserProfile profile) async {
    if (!validateUserProfile(profile)) {
      throw ArgumentError('Invalid user profile data');
    }

    // Check if user with email already exists
    final existingUser = await getUserByEmail(profile.email);
    if (existingUser != null) {
      throw ArgumentError('User with email ${profile.email} already exists');
    }

    await createWithId(profile.userId, profile);
    return profile.userId;
  }

  /// Update user with validation
  Future<void> updateValidatedUser(String userId, UserProfile profile) async {
    if (!validateUserProfile(profile)) {
      throw ArgumentError('Invalid user profile data');
    }

    final updatedProfile = profile.copyWith(updatedAt: DateTime.now());

    await update(userId, updatedProfile);
  }
}

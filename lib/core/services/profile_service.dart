import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/user_models.dart';
import '../repositories/user_repository.dart';
import 'auth_service.dart';

/// Service for managing user profile operations
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final UserRepository _userRepository = UserRepository();
  final AuthService _authService = AuthService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Update user profile
  Future<UserProfile> updateProfile(UserProfile updatedProfile) async {
    try {
      if (!_authService.isSignedIn) {
        throw Exception('User not authenticated');
      }

      final userId = _authService.currentUserId!;

      // Validate the updated profile
      if (!_userRepository.validateUserProfile(updatedProfile)) {
        throw ArgumentError('Invalid profile data');
      }

      // Ensure the profile has the correct user ID and update timestamp
      final profileToUpdate = updatedProfile.copyWith(
        userId: userId,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _userRepository.updateValidatedUser(userId, profileToUpdate);

      // Refresh the auth service's cached profile
      await _authService.refreshUserProfile();

      return profileToUpdate;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update specific profile fields
  Future<void> updateProfileFields(Map<String, dynamic> fields) async {
    try {
      if (!_authService.isSignedIn) {
        throw Exception('User not authenticated');
      }

      final userId = _authService.currentUserId!;

      // Add update timestamp
      fields['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      await _userRepository.updateFields(userId, fields);
      await _authService.refreshUserProfile();
    } catch (e) {
      throw Exception('Failed to update profile fields: $e');
    }
  }

  /// Update lawyer profile
  Future<void> updateLawyerProfile(LawyerProfile lawyerProfile) async {
    try {
      if (!_authService.isSignedIn) {
        throw Exception('User not authenticated');
      }

      if (_authService.userRole != UserRole.lawyer) {
        throw Exception('User is not a lawyer');
      }

      if (!lawyerProfile.isValid()) {
        throw ArgumentError('Invalid lawyer profile data');
      }

      await updateProfileFields({'lawyerProfile': lawyerProfile.toFirestore()});
    } catch (e) {
      throw Exception('Failed to update lawyer profile: $e');
    }
  }

  /// Update court master profile
  Future<void> updateCourtMasterProfile(
    CourtMasterProfile courtMasterProfile,
  ) async {
    try {
      if (!_authService.isSignedIn) {
        throw Exception('User not authenticated');
      }

      if (_authService.userRole != UserRole.courtMaster) {
        throw Exception('User is not a court master');
      }

      if (!courtMasterProfile.isValid()) {
        throw ArgumentError('Invalid court master profile data');
      }

      await updateProfileFields({
        'courtMasterProfile': courtMasterProfile.toFirestore(),
      });
    } catch (e) {
      throw Exception('Failed to update court master profile: $e');
    }
  }

  /// Update judge profile
  Future<void> updateJudgeProfile(JudgeProfile judgeProfile) async {
    try {
      if (!_authService.isSignedIn) {
        throw Exception('User not authenticated');
      }

      if (_authService.userRole != UserRole.judge) {
        throw Exception('User is not a judge');
      }

      if (!judgeProfile.isValid()) {
        throw ArgumentError('Invalid judge profile data');
      }

      await updateProfileFields({'judgeProfile': judgeProfile.toFirestore()});
    } catch (e) {
      throw Exception('Failed to update judge profile: $e');
    }
  }

  /// Upload profile image
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      if (!_authService.isSignedIn) {
        throw Exception('User not authenticated');
      }

      final userId = _authService.currentUserId!;

      // Validate file size (max 5MB)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Image file too large. Maximum size is 5MB');
      }

      // Create storage reference
      final storageRef = _storage
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      // Upload file
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user profile with new image URL
      await _userRepository.updateProfileImage(userId, downloadUrl);
      await _authService.refreshUserProfile();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Delete profile image
  Future<void> deleteProfileImage() async {
    try {
      if (!_authService.isSignedIn) {
        throw Exception('User not authenticated');
      }

      final userId = _authService.currentUserId!;
      final currentProfile = _authService.currentUserProfile;

      if (currentProfile?.profileImageUrl != null) {
        // Delete from Firebase Storage
        try {
          final storageRef = _storage.refFromURL(
            currentProfile!.profileImageUrl!,
          );
          await storageRef.delete();
        } catch (e) {
          debugPrint('Error deleting image from storage: $e');
          // Continue even if storage deletion fails
        }

        // Remove URL from user profile
        await _userRepository.updateProfileImage(userId, '');
        await _authService.refreshUserProfile();
      }
    } catch (e) {
      throw Exception('Failed to delete profile image: $e');
    }
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      if (!_authService.isSignedIn) {
        throw Exception('User not authenticated');
      }

      final userId = _authService.currentUserId!;
      await _userRepository.updateNotificationPreferences(userId, preferences);
      await _authService.refreshUserProfile();
    } catch (e) {
      throw Exception('Failed to update notification preferences: $e');
    }
  }

  /// Get current user profile
  Future<UserProfile?> getCurrentProfile() async {
    try {
      if (!_authService.isSignedIn) {
        return null;
      }

      final userId = _authService.currentUserId!;
      return await _userRepository.getById(userId);
    } catch (e) {
      debugPrint('Error getting current profile: $e');
      return null;
    }
  }

  /// Refresh current user profile from Firestore
  Future<UserProfile?> refreshCurrentProfile() async {
    try {
      await _authService.refreshUserProfile();
      return _authService.currentUserProfile;
    } catch (e) {
      debugPrint('Error refreshing current profile: $e');
      return null;
    }
  }

  /// Update display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      if (!_authService.isSignedIn) {
        throw Exception('User not authenticated');
      }

      if (displayName.trim().isEmpty) {
        throw ArgumentError('Display name cannot be empty');
      }

      // Update in Firebase Auth
      await _authService.currentUser!.updateDisplayName(displayName.trim());

      // Update in Firestore
      await updateProfileFields({'displayName': displayName.trim()});
    } catch (e) {
      throw Exception('Failed to update display name: $e');
    }
  }

  /// Validate profile completeness
  bool isProfileComplete(UserProfile profile) {
    // Check common required fields
    if (profile.displayName.isEmpty || profile.email.isEmpty) {
      return false;
    }

    // Check role-specific completeness
    switch (profile.role) {
      case UserRole.lawyer:
        return profile.lawyerProfile != null &&
            profile.lawyerProfile!.isValid();
      case UserRole.courtMaster:
        return profile.courtMasterProfile != null &&
            profile.courtMasterProfile!.isValid();
      case UserRole.judge:
        return profile.judgeProfile != null && profile.judgeProfile!.isValid();
    }
  }

  /// Get profile completion percentage
  double getProfileCompletionPercentage(UserProfile profile) {
    int totalFields = 0;
    int completedFields = 0;

    // Common fields
    totalFields +=
        4; // displayName, email, profileImage, notificationPreferences
    if (profile.displayName.isNotEmpty) completedFields++;
    if (profile.email.isNotEmpty) completedFields++;
    if (profile.profileImageUrl != null &&
        profile.profileImageUrl!.isNotEmpty) {
      completedFields++;
    }
    completedFields++; // notificationPreferences always exist

    // Role-specific fields
    switch (profile.role) {
      case UserRole.lawyer:
        totalFields +=
            6; // barCouncilId, state, practiceAreas, year, address, phone
        if (profile.lawyerProfile != null) {
          final lawyer = profile.lawyerProfile!;
          if (lawyer.barCouncilId.isNotEmpty) completedFields++;
          if (lawyer.barCouncilState.isNotEmpty) completedFields++;
          if (lawyer.practiceAreas.isNotEmpty) completedFields++;
          if (lawyer.enrollmentYear > 1900) completedFields++;
          if (lawyer.address.isNotEmpty) completedFields++;
          if (lawyer.phoneNumber.isNotEmpty) completedFields++;
        }
        break;
      case UserRole.courtMaster:
        totalFields += 4; // employeeId, courtId, designation, permissions
        if (profile.courtMasterProfile != null) {
          final courtMaster = profile.courtMasterProfile!;
          if (courtMaster.employeeId.isNotEmpty) completedFields++;
          if (courtMaster.courtId.isNotEmpty) completedFields++;
          if (courtMaster.designation.isNotEmpty) completedFields++;
          if (courtMaster.permissions.isNotEmpty) completedFields++;
        }
        break;
      case UserRole.judge:
        totalFields +=
            5; // judgeId, designation, courtId, courtrooms, specialization
        if (profile.judgeProfile != null) {
          final judge = profile.judgeProfile!;
          if (judge.judgeId.isNotEmpty) completedFields++;
          if (judge.designation.isNotEmpty) completedFields++;
          if (judge.courtId.isNotEmpty) completedFields++;
          if (judge.assignedCourtrooms.isNotEmpty) completedFields++;
          if (judge.specialization.isNotEmpty) completedFields++;
        }
        break;
    }

    return totalFields > 0 ? (completedFields / totalFields) * 100 : 0;
  }

  /// Get missing profile fields
  List<String> getMissingProfileFields(UserProfile profile) {
    final missingFields = <String>[];

    // Check common fields
    if (profile.displayName.isEmpty) missingFields.add('Display Name');
    if (profile.email.isEmpty) missingFields.add('Email');
    if (profile.profileImageUrl == null || profile.profileImageUrl!.isEmpty) {
      missingFields.add('Profile Image');
    }

    // Check role-specific fields
    switch (profile.role) {
      case UserRole.lawyer:
        if (profile.lawyerProfile == null) {
          missingFields.add('Lawyer Profile');
        } else {
          final lawyer = profile.lawyerProfile!;
          if (lawyer.barCouncilId.isEmpty) {
            missingFields.add('Bar Council ID');
          }
          if (lawyer.barCouncilState.isEmpty) {
            missingFields.add('Bar Council State');
          }
          if (lawyer.practiceAreas.isEmpty) {
            missingFields.add('Practice Areas');
          }
          if (lawyer.enrollmentYear <= 1900) {
            missingFields.add('Enrollment Year');
          }
          if (lawyer.address.isEmpty) {
            missingFields.add('Address');
          }
          if (lawyer.phoneNumber.isEmpty) {
            missingFields.add('Phone Number');
          }
        }
        break;
      case UserRole.courtMaster:
        if (profile.courtMasterProfile == null) {
          missingFields.add('Court Master Profile');
        } else {
          final courtMaster = profile.courtMasterProfile!;
          if (courtMaster.employeeId.isEmpty) {
            missingFields.add('Employee ID');
          }
          if (courtMaster.courtId.isEmpty) {
            missingFields.add('Court ID');
          }
          if (courtMaster.designation.isEmpty) {
            missingFields.add('Designation');
          }
          if (courtMaster.permissions.isEmpty) {
            missingFields.add('Permissions');
          }
        }
        break;
      case UserRole.judge:
        if (profile.judgeProfile == null) {
          missingFields.add('Judge Profile');
        } else {
          final judge = profile.judgeProfile!;
          if (judge.judgeId.isEmpty) {
            missingFields.add('Judge ID');
          }
          if (judge.designation.isEmpty) {
            missingFields.add('Designation');
          }
          if (judge.courtId.isEmpty) {
            missingFields.add('Court ID');
          }
          if (judge.assignedCourtrooms.isEmpty) {
            missingFields.add('Assigned Courtrooms');
          }
          if (judge.specialization.isEmpty) {
            missingFields.add('Specialization');
          }
        }
        break;
    }

    return missingFields;
  }

  /// Export profile data (for data portability)
  Map<String, dynamic> exportProfileData(UserProfile profile) {
    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profile.toFirestore(),
    };
  }
}

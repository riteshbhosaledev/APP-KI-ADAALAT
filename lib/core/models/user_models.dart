import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for user roles in the court system
enum UserRole {
  lawyer,
  courtMaster,
  judge;

  /// Convert enum to string for Firestore storage
  String toFirestore() {
    switch (this) {
      case UserRole.lawyer:
        return 'lawyer';
      case UserRole.courtMaster:
        return 'court_master';
      case UserRole.judge:
        return 'judge';
    }
  }

  /// Create enum from Firestore string
  static UserRole fromFirestore(String value) {
    switch (value) {
      case 'lawyer':
        return UserRole.lawyer;
      case 'court_master':
        return UserRole.courtMaster;
      case 'judge':
        return UserRole.judge;
      default:
        throw ArgumentError('Invalid user role: $value');
    }
  }
}

/// Notification preferences for users
class NotificationPreferences {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool hearingReminders;

  const NotificationPreferences({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.hearingReminders = true,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'hearingReminders': hearingReminders,
    };
  }

  /// Create from Firestore map
  factory NotificationPreferences.fromFirestore(Map<String, dynamic> data) {
    return NotificationPreferences(
      pushNotifications: data['pushNotifications'] ?? true,
      emailNotifications: data['emailNotifications'] ?? true,
      smsNotifications: data['smsNotifications'] ?? false,
      hearingReminders: data['hearingReminders'] ?? true,
    );
  }

  /// Create copy with updated values
  NotificationPreferences copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? hearingReminders,
  }) {
    return NotificationPreferences(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      hearingReminders: hearingReminders ?? this.hearingReminders,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationPreferences &&
        other.pushNotifications == pushNotifications &&
        other.emailNotifications == emailNotifications &&
        other.smsNotifications == smsNotifications &&
        other.hearingReminders == hearingReminders;
  }

  @override
  int get hashCode {
    return pushNotifications.hashCode ^
        emailNotifications.hashCode ^
        smsNotifications.hashCode ^
        hearingReminders.hashCode;
  }
}

/// User statistics for quick access
class UserStats {
  final int totalCases;
  final int activeCases;
  final int completedCases;
  final DateTime? lastLoginAt;

  const UserStats({
    this.totalCases = 0,
    this.activeCases = 0,
    this.completedCases = 0,
    this.lastLoginAt,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'totalCases': totalCases,
      'activeCases': activeCases,
      'completedCases': completedCases,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
    };
  }

  /// Create from Firestore map
  factory UserStats.fromFirestore(Map<String, dynamic> data) {
    return UserStats(
      totalCases: data['totalCases'] ?? 0,
      activeCases: data['activeCases'] ?? 0,
      completedCases: data['completedCases'] ?? 0,
      lastLoginAt: data['lastLoginAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastLoginAt'])
          : null,
    );
  }

  /// Create copy with updated values
  UserStats copyWith({
    int? totalCases,
    int? activeCases,
    int? completedCases,
    DateTime? lastLoginAt,
  }) {
    return UserStats(
      totalCases: totalCases ?? this.totalCases,
      activeCases: activeCases ?? this.activeCases,
      completedCases: completedCases ?? this.completedCases,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStats &&
        other.totalCases == totalCases &&
        other.activeCases == activeCases &&
        other.completedCases == completedCases &&
        other.lastLoginAt == lastLoginAt;
  }

  @override
  int get hashCode {
    return totalCases.hashCode ^
        activeCases.hashCode ^
        completedCases.hashCode ^
        lastLoginAt.hashCode;
  }
}

/// Lawyer-specific profile information
class LawyerProfile {
  final String barCouncilId;
  final String barCouncilState;
  final List<String> practiceAreas;
  final int enrollmentYear;
  final String? firmName;
  final String address;
  final String phoneNumber;

  const LawyerProfile({
    required this.barCouncilId,
    required this.barCouncilState,
    required this.practiceAreas,
    required this.enrollmentYear,
    this.firmName,
    required this.address,
    required this.phoneNumber,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'barCouncilId': barCouncilId,
      'barCouncilState': barCouncilState,
      'practiceAreas': practiceAreas,
      'enrollmentYear': enrollmentYear,
      'firmName': firmName,
      'address': address,
      'phoneNumber': phoneNumber,
    };
  }

  /// Create from Firestore map
  factory LawyerProfile.fromFirestore(Map<String, dynamic> data) {
    return LawyerProfile(
      barCouncilId: data['barCouncilId'] ?? '',
      barCouncilState: data['barCouncilState'] ?? '',
      practiceAreas: List<String>.from(data['practiceAreas'] ?? []),
      enrollmentYear: data['enrollmentYear'] ?? 0,
      firmName: data['firmName'],
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }

  /// Validate lawyer profile data
  bool isValid() {
    return barCouncilId.isNotEmpty &&
        barCouncilState.isNotEmpty &&
        practiceAreas.isNotEmpty &&
        enrollmentYear > 1900 &&
        address.isNotEmpty &&
        phoneNumber.isNotEmpty;
  }

  /// Create copy with updated values
  LawyerProfile copyWith({
    String? barCouncilId,
    String? barCouncilState,
    List<String>? practiceAreas,
    int? enrollmentYear,
    String? firmName,
    String? address,
    String? phoneNumber,
  }) {
    return LawyerProfile(
      barCouncilId: barCouncilId ?? this.barCouncilId,
      barCouncilState: barCouncilState ?? this.barCouncilState,
      practiceAreas: practiceAreas ?? this.practiceAreas,
      enrollmentYear: enrollmentYear ?? this.enrollmentYear,
      firmName: firmName ?? this.firmName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LawyerProfile &&
        other.barCouncilId == barCouncilId &&
        other.barCouncilState == barCouncilState &&
        other.practiceAreas.toString() == practiceAreas.toString() &&
        other.enrollmentYear == enrollmentYear &&
        other.firmName == firmName &&
        other.address == address &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return barCouncilId.hashCode ^
        barCouncilState.hashCode ^
        practiceAreas.hashCode ^
        enrollmentYear.hashCode ^
        firmName.hashCode ^
        address.hashCode ^
        phoneNumber.hashCode;
  }
}

/// Court Master-specific profile information
class CourtMasterProfile {
  final String employeeId;
  final String courtId;
  final String designation;
  final List<String> permissions;
  final List<String> assignedCourtrooms;

  const CourtMasterProfile({
    required this.employeeId,
    required this.courtId,
    required this.designation,
    required this.permissions,
    required this.assignedCourtrooms,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'courtId': courtId,
      'designation': designation,
      'permissions': permissions,
      'assignedCourtrooms': assignedCourtrooms,
    };
  }

  /// Create from Firestore map
  factory CourtMasterProfile.fromFirestore(Map<String, dynamic> data) {
    return CourtMasterProfile(
      employeeId: data['employeeId'] ?? '',
      courtId: data['courtId'] ?? '',
      designation: data['designation'] ?? '',
      permissions: List<String>.from(data['permissions'] ?? []),
      assignedCourtrooms: List<String>.from(data['assignedCourtrooms'] ?? []),
    );
  }

  /// Validate court master profile data
  bool isValid() {
    return employeeId.isNotEmpty &&
        courtId.isNotEmpty &&
        designation.isNotEmpty &&
        permissions.isNotEmpty;
  }

  /// Create copy with updated values
  CourtMasterProfile copyWith({
    String? employeeId,
    String? courtId,
    String? designation,
    List<String>? permissions,
    List<String>? assignedCourtrooms,
  }) {
    return CourtMasterProfile(
      employeeId: employeeId ?? this.employeeId,
      courtId: courtId ?? this.courtId,
      designation: designation ?? this.designation,
      permissions: permissions ?? this.permissions,
      assignedCourtrooms: assignedCourtrooms ?? this.assignedCourtrooms,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourtMasterProfile &&
        other.employeeId == employeeId &&
        other.courtId == courtId &&
        other.designation == designation &&
        other.permissions.toString() == permissions.toString() &&
        other.assignedCourtrooms.toString() == assignedCourtrooms.toString();
  }

  @override
  int get hashCode {
    return employeeId.hashCode ^
        courtId.hashCode ^
        designation.hashCode ^
        permissions.hashCode ^
        assignedCourtrooms.hashCode;
  }
}

/// Judge-specific profile information
class JudgeProfile {
  final String judgeId;
  final String designation;
  final String courtId;
  final List<String> assignedCourtrooms;
  final DateTime appointmentDate;
  final List<String> specialization;

  const JudgeProfile({
    required this.judgeId,
    required this.designation,
    required this.courtId,
    required this.assignedCourtrooms,
    required this.appointmentDate,
    required this.specialization,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'judgeId': judgeId,
      'designation': designation,
      'courtId': courtId,
      'assignedCourtrooms': assignedCourtrooms,
      'appointmentDate': appointmentDate.millisecondsSinceEpoch,
      'specialization': specialization,
    };
  }

  /// Create from Firestore map
  factory JudgeProfile.fromFirestore(Map<String, dynamic> data) {
    return JudgeProfile(
      judgeId: data['judgeId'] ?? '',
      designation: data['designation'] ?? '',
      courtId: data['courtId'] ?? '',
      assignedCourtrooms: List<String>.from(data['assignedCourtrooms'] ?? []),
      appointmentDate: data['appointmentDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['appointmentDate'])
          : DateTime.now(),
      specialization: List<String>.from(data['specialization'] ?? []),
    );
  }

  /// Validate judge profile data
  bool isValid() {
    return judgeId.isNotEmpty &&
        designation.isNotEmpty &&
        courtId.isNotEmpty &&
        assignedCourtrooms.isNotEmpty;
  }

  /// Create copy with updated values
  JudgeProfile copyWith({
    String? judgeId,
    String? designation,
    String? courtId,
    List<String>? assignedCourtrooms,
    DateTime? appointmentDate,
    List<String>? specialization,
  }) {
    return JudgeProfile(
      judgeId: judgeId ?? this.judgeId,
      designation: designation ?? this.designation,
      courtId: courtId ?? this.courtId,
      assignedCourtrooms: assignedCourtrooms ?? this.assignedCourtrooms,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      specialization: specialization ?? this.specialization,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JudgeProfile &&
        other.judgeId == judgeId &&
        other.designation == designation &&
        other.courtId == courtId &&
        other.assignedCourtrooms.toString() == assignedCourtrooms.toString() &&
        other.appointmentDate == appointmentDate &&
        other.specialization.toString() == specialization.toString();
  }

  @override
  int get hashCode {
    return judgeId.hashCode ^
        designation.hashCode ^
        courtId.hashCode ^
        assignedCourtrooms.hashCode ^
        appointmentDate.hashCode ^
        specialization.hashCode;
  }
}

/// Main user profile class that contains common fields and role-specific profiles
class UserProfile {
  final String userId;
  final String email;
  final String displayName;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImageUrl;
  final NotificationPreferences notificationPreferences;
  final UserStats stats;

  // Role-specific profiles (only one will be non-null based on role)
  final LawyerProfile? lawyerProfile;
  final CourtMasterProfile? courtMasterProfile;
  final JudgeProfile? judgeProfile;

  const UserProfile({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
    this.notificationPreferences = const NotificationPreferences(),
    this.stats = const UserStats(),
    this.lawyerProfile,
    this.courtMasterProfile,
    this.judgeProfile,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'role': role.toFirestore(),
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'profileImageUrl': profileImageUrl,
      'notificationPreferences': notificationPreferences.toFirestore(),
      'stats': stats.toFirestore(),
    };

    // Add role-specific profile data
    switch (role) {
      case UserRole.lawyer:
        if (lawyerProfile != null) {
          data['lawyerProfile'] = lawyerProfile!.toFirestore();
        }
        break;
      case UserRole.courtMaster:
        if (courtMasterProfile != null) {
          data['courtMasterProfile'] = courtMasterProfile!.toFirestore();
        }
        break;
      case UserRole.judge:
        if (judgeProfile != null) {
          data['judgeProfile'] = judgeProfile!.toFirestore();
        }
        break;
    }

    return data;
  }

  /// Create from Firestore document
  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final role = UserRole.fromFirestore(data['role']);

    return UserProfile(
      userId: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: role,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : DateTime.now(),
      profileImageUrl: data['profileImageUrl'],
      notificationPreferences: data['notificationPreferences'] != null
          ? NotificationPreferences.fromFirestore(
              data['notificationPreferences'],
            )
          : const NotificationPreferences(),
      stats: data['stats'] != null
          ? UserStats.fromFirestore(data['stats'])
          : const UserStats(),
      lawyerProfile: role == UserRole.lawyer && data['lawyerProfile'] != null
          ? LawyerProfile.fromFirestore(data['lawyerProfile'])
          : null,
      courtMasterProfile:
          role == UserRole.courtMaster && data['courtMasterProfile'] != null
          ? CourtMasterProfile.fromFirestore(data['courtMasterProfile'])
          : null,
      judgeProfile: role == UserRole.judge && data['judgeProfile'] != null
          ? JudgeProfile.fromFirestore(data['judgeProfile'])
          : null,
    );
  }

  /// Validate user profile based on role
  bool isValid() {
    // Common validation
    if (userId.isEmpty || email.isEmpty || displayName.isEmpty) {
      return false;
    }

    // Role-specific validation
    switch (role) {
      case UserRole.lawyer:
        return lawyerProfile != null && lawyerProfile!.isValid();
      case UserRole.courtMaster:
        return courtMasterProfile != null && courtMasterProfile!.isValid();
      case UserRole.judge:
        return judgeProfile != null && judgeProfile!.isValid();
    }
  }

  /// Create copy with updated values
  UserProfile copyWith({
    String? userId,
    String? email,
    String? displayName,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
    NotificationPreferences? notificationPreferences,
    UserStats? stats,
    LawyerProfile? lawyerProfile,
    CourtMasterProfile? courtMasterProfile,
    JudgeProfile? judgeProfile,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      stats: stats ?? this.stats,
      lawyerProfile: lawyerProfile ?? this.lawyerProfile,
      courtMasterProfile: courtMasterProfile ?? this.courtMasterProfile,
      judgeProfile: judgeProfile ?? this.judgeProfile,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.userId == userId &&
        other.email == email &&
        other.displayName == displayName &&
        other.role == role &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.profileImageUrl == profileImageUrl &&
        other.notificationPreferences == notificationPreferences &&
        other.stats == stats &&
        other.lawyerProfile == lawyerProfile &&
        other.courtMasterProfile == courtMasterProfile &&
        other.judgeProfile == judgeProfile;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        role.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        profileImageUrl.hashCode ^
        notificationPreferences.hashCode ^
        stats.hashCode ^
        lawyerProfile.hashCode ^
        courtMasterProfile.hashCode ^
        judgeProfile.hashCode;
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, email: $email, displayName: $displayName, role: $role)';
  }
}

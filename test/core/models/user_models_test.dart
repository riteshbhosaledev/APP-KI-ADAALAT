import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nyaay_dhrishti/core/models/user_models.dart';

void main() {
  group('UserRole', () {
    test('should convert to and from Firestore correctly', () {
      expect(UserRole.lawyer.toFirestore(), equals('lawyer'));
      expect(UserRole.courtMaster.toFirestore(), equals('court_master'));
      expect(UserRole.judge.toFirestore(), equals('judge'));

      expect(UserRole.fromFirestore('lawyer'), equals(UserRole.lawyer));
      expect(
        UserRole.fromFirestore('court_master'),
        equals(UserRole.courtMaster),
      );
      expect(UserRole.fromFirestore('judge'), equals(UserRole.judge));
    });

    test('should throw error for invalid role string', () {
      expect(() => UserRole.fromFirestore('invalid'), throwsArgumentError);
    });
  });

  group('NotificationPreferences', () {
    test('should create with default values', () {
      const prefs = NotificationPreferences();
      expect(prefs.pushNotifications, isTrue);
      expect(prefs.emailNotifications, isTrue);
      expect(prefs.smsNotifications, isFalse);
      expect(prefs.hearingReminders, isTrue);
    });

    test('should convert to and from Firestore correctly', () {
      const prefs = NotificationPreferences(
        pushNotifications: false,
        emailNotifications: true,
        smsNotifications: true,
        hearingReminders: false,
      );

      final firestoreData = prefs.toFirestore();
      final reconstructed = NotificationPreferences.fromFirestore(
        firestoreData,
      );

      expect(reconstructed, equals(prefs));
    });

    test('should create copy with updated values', () {
      const original = NotificationPreferences();
      final updated = original.copyWith(pushNotifications: false);

      expect(updated.pushNotifications, isFalse);
      expect(updated.emailNotifications, isTrue); // unchanged
    });
  });

  group('LawyerProfile', () {
    test('should validate correctly', () {
      const validProfile = LawyerProfile(
        barCouncilId: 'BC123',
        barCouncilState: 'Delhi',
        practiceAreas: ['Criminal Law'],
        enrollmentYear: 2020,
        address: '123 Main St',
        phoneNumber: '9876543210',
      );

      expect(validProfile.isValid(), isTrue);

      const invalidProfile = LawyerProfile(
        barCouncilId: '',
        barCouncilState: 'Delhi',
        practiceAreas: ['Criminal Law'],
        enrollmentYear: 2020,
        address: '123 Main St',
        phoneNumber: '9876543210',
      );

      expect(invalidProfile.isValid(), isFalse);
    });

    test('should convert to and from Firestore correctly', () {
      const profile = LawyerProfile(
        barCouncilId: 'BC123',
        barCouncilState: 'Delhi',
        practiceAreas: ['Criminal Law', 'Civil Law'],
        enrollmentYear: 2020,
        firmName: 'Test Firm',
        address: '123 Main St',
        phoneNumber: '9876543210',
      );

      final firestoreData = profile.toFirestore();
      final reconstructed = LawyerProfile.fromFirestore(firestoreData);

      expect(reconstructed, equals(profile));
    });
  });

  group('UserProfile', () {
    test('should validate lawyer profile correctly', () {
      final validLawyerProfile = UserProfile(
        userId: 'user123',
        email: 'lawyer@test.com',
        displayName: 'Test Lawyer',
        role: UserRole.lawyer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lawyerProfile: const LawyerProfile(
          barCouncilId: 'BC123',
          barCouncilState: 'Delhi',
          practiceAreas: ['Criminal Law'],
          enrollmentYear: 2020,
          address: '123 Main St',
          phoneNumber: '9876543210',
        ),
      );

      expect(validLawyerProfile.isValid(), isTrue);
    });

    test('should convert to Firestore correctly', () {
      final profile = UserProfile(
        userId: 'user123',
        email: 'lawyer@test.com',
        displayName: 'Test Lawyer',
        role: UserRole.lawyer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lawyerProfile: const LawyerProfile(
          barCouncilId: 'BC123',
          barCouncilState: 'Delhi',
          practiceAreas: ['Criminal Law'],
          enrollmentYear: 2020,
          address: '123 Main St',
          phoneNumber: '9876543210',
        ),
      );

      final firestoreData = profile.toFirestore();

      expect(firestoreData['userId'], equals('user123'));
      expect(firestoreData['email'], equals('lawyer@test.com'));
      expect(firestoreData['role'], equals('lawyer'));
      expect(firestoreData['lawyerProfile'], isNotNull);
      expect(firestoreData['courtMasterProfile'], isNull);
      expect(firestoreData['judgeProfile'], isNull);
    });

    test('should create copy with updated values', () {
      final original = UserProfile(
        userId: 'user123',
        email: 'lawyer@test.com',
        displayName: 'Test Lawyer',
        role: UserRole.lawyer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(displayName: 'Updated Name');

      expect(updated.displayName, equals('Updated Name'));
      expect(updated.email, equals('lawyer@test.com')); // unchanged
    });
  });
}

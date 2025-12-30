import 'package:flutter/foundation.dart';
import '../models/case_models.dart';
import '../models/user_models.dart';
import '../models/case_version_models.dart';
import '../repositories/case_repository.dart';
import '../repositories/user_repository.dart';
import 'case_version_service.dart';

/// Exception thrown when referential integrity is violated
class ReferentialIntegrityException implements Exception {
  final String message;
  const ReferentialIntegrityException(this.message);

  @override
  String toString() => 'ReferentialIntegrityException: $message';
}

/// Exception thrown when role validation fails
class RoleValidationException implements Exception {
  final String message;
  const RoleValidationException(this.message);

  @override
  String toString() => 'RoleValidationException: $message';
}

/// Service for managing case assignments with referential integrity
class CaseAssignmentService {
  final CaseRepository _caseRepository;
  final UserRepository _userRepository;
  final CaseVersionService _versionService;

  CaseAssignmentService({
    CaseRepository? caseRepository,
    UserRepository? userRepository,
    CaseVersionService? versionService,
  }) : _caseRepository = caseRepository ?? CaseRepository(),
       _userRepository = userRepository ?? UserRepository(),
       _versionService = versionService ?? CaseVersionService();

  /// Assign a lawyer to a case as petitioner's counsel
  Future<void> assignPetitionerLawyer(
    String caseId,
    String lawyerId,
    String assignedBy, {
    String? reason,
  }) async {
    try {
      // Validate lawyer exists and has correct role
      await _validateUserRole(lawyerId, UserRole.lawyer);

      // Get current case
      final currentCase = await _caseRepository.getById(caseId);
      if (currentCase == null) {
        throw ReferentialIntegrityException('Case not found: $caseId');
      }

      // Update petitioner with lawyer assignment
      final updatedPetitioner = currentCase.petitioner.copyWith(
        lawyerId: lawyerId,
      );
      final updatedCase = currentCase.copyWith(
        petitioner: updatedPetitioner,
        updatedAt: DateTime.now(),
        lastModifiedBy: assignedBy,
      );

      // Update with versioning
      await _versionService.updateCaseWithVersioning(
        caseId,
        updatedCase,
        assignedBy,
        changeReason: reason ?? 'Petitioner lawyer assigned: $lawyerId',
      );

      debugPrint('Petitioner lawyer assigned: $lawyerId to case $caseId');
    } catch (e) {
      debugPrint('Error assigning petitioner lawyer: $e');
      rethrow;
    }
  }

  /// Assign a lawyer to a case as respondent's counsel
  Future<void> assignRespondentLawyer(
    String caseId,
    String lawyerId,
    String assignedBy, {
    String? reason,
  }) async {
    try {
      // Validate lawyer exists and has correct role
      await _validateUserRole(lawyerId, UserRole.lawyer);

      // Get current case
      final currentCase = await _caseRepository.getById(caseId);
      if (currentCase == null) {
        throw ReferentialIntegrityException('Case not found: $caseId');
      }

      // Update respondent with lawyer assignment
      final updatedRespondent = currentCase.respondent.copyWith(
        lawyerId: lawyerId,
      );
      final updatedCase = currentCase.copyWith(
        respondent: updatedRespondent,
        updatedAt: DateTime.now(),
        lastModifiedBy: assignedBy,
      );

      // Update with versioning
      await _versionService.updateCaseWithVersioning(
        caseId,
        updatedCase,
        assignedBy,
        changeReason: reason ?? 'Respondent lawyer assigned: $lawyerId',
      );

      debugPrint('Respondent lawyer assigned: $lawyerId to case $caseId');
    } catch (e) {
      debugPrint('Error assigning respondent lawyer: $e');
      rethrow;
    }
  }

  /// Assign a judge to a case
  Future<void> assignJudge(
    String caseId,
    String judgeId,
    String assignedBy, {
    String? reason,
  }) async {
    try {
      // Validate judge exists and has correct role
      await _validateUserRole(judgeId, UserRole.judge);

      // Get current case
      final currentCase = await _caseRepository.getById(caseId);
      if (currentCase == null) {
        throw ReferentialIntegrityException('Case not found: $caseId');
      }

      // Validate judge is assigned to the same court
      await _validateJudgeCourtAssignment(judgeId, currentCase.courtId);

      // Assign judge with versioning
      await _versionService.assignJudgeWithVersioning(
        caseId,
        judgeId,
        assignedBy,
        reason: reason,
      );

      debugPrint('Judge assigned: $judgeId to case $caseId');
    } catch (e) {
      debugPrint('Error assigning judge: $e');
      rethrow;
    }
  }

  /// Assign a courtroom to a case
  Future<void> assignCourtroom(
    String caseId,
    String courtroom,
    String assignedBy, {
    String? reason,
  }) async {
    try {
      // Get current case
      final currentCase = await _caseRepository.getById(caseId);
      if (currentCase == null) {
        throw ReferentialIntegrityException('Case not found: $caseId');
      }

      // Validate courtroom assignment if judge is already assigned
      if (currentCase.assignedJudgeId != null) {
        await _validateJudgeCourtroomAssignment(
          currentCase.assignedJudgeId!,
          courtroom,
        );
      }

      // Update case with courtroom assignment
      final updatedCase = currentCase.copyWith(
        courtroom: courtroom,
        updatedAt: DateTime.now(),
        lastModifiedBy: assignedBy,
      );

      // Update with versioning
      await _versionService.updateCaseWithVersioning(
        caseId,
        updatedCase,
        assignedBy,
        changeReason: reason ?? 'Courtroom assigned: $courtroom',
      );

      debugPrint('Courtroom assigned: $courtroom to case $caseId');
    } catch (e) {
      debugPrint('Error assigning courtroom: $e');
      rethrow;
    }
  }

  /// Remove lawyer assignment from petitioner
  Future<void> removePetitionerLawyer(
    String caseId,
    String removedBy, {
    String? reason,
  }) async {
    try {
      // Get current case
      final currentCase = await _caseRepository.getById(caseId);
      if (currentCase == null) {
        throw ReferentialIntegrityException('Case not found: $caseId');
      }

      // Update petitioner to remove lawyer assignment
      final updatedPetitioner = currentCase.petitioner.copyWith(lawyerId: null);
      final updatedCase = currentCase.copyWith(
        petitioner: updatedPetitioner,
        updatedAt: DateTime.now(),
        lastModifiedBy: removedBy,
      );

      // Update with versioning
      await _versionService.updateCaseWithVersioning(
        caseId,
        updatedCase,
        removedBy,
        changeReason: reason ?? 'Petitioner lawyer assignment removed',
      );

      debugPrint('Petitioner lawyer assignment removed from case $caseId');
    } catch (e) {
      debugPrint('Error removing petitioner lawyer: $e');
      rethrow;
    }
  }

  /// Remove lawyer assignment from respondent
  Future<void> removeRespondentLawyer(
    String caseId,
    String removedBy, {
    String? reason,
  }) async {
    try {
      // Get current case
      final currentCase = await _caseRepository.getById(caseId);
      if (currentCase == null) {
        throw ReferentialIntegrityException('Case not found: $caseId');
      }

      // Update respondent to remove lawyer assignment
      final updatedRespondent = currentCase.respondent.copyWith(lawyerId: null);
      final updatedCase = currentCase.copyWith(
        respondent: updatedRespondent,
        updatedAt: DateTime.now(),
        lastModifiedBy: removedBy,
      );

      // Update with versioning
      await _versionService.updateCaseWithVersioning(
        caseId,
        updatedCase,
        removedBy,
        changeReason: reason ?? 'Respondent lawyer assignment removed',
      );

      debugPrint('Respondent lawyer assignment removed from case $caseId');
    } catch (e) {
      debugPrint('Error removing respondent lawyer: $e');
      rethrow;
    }
  }

  /// Remove judge assignment from case
  Future<void> removeJudge(
    String caseId,
    String removedBy, {
    String? reason,
  }) async {
    try {
      // Get current case
      final currentCase = await _caseRepository.getById(caseId);
      if (currentCase == null) {
        throw ReferentialIntegrityException('Case not found: $caseId');
      }

      // Update case to remove judge assignment
      final updatedCase = currentCase.copyWith(
        assignedJudgeId: null,
        updatedAt: DateTime.now(),
        lastModifiedBy: removedBy,
      );

      // Update with versioning
      await _versionService.updateCaseWithVersioning(
        caseId,
        updatedCase,
        removedBy,
        changeReason: reason ?? 'Judge assignment removed',
      );

      debugPrint('Judge assignment removed from case $caseId');
    } catch (e) {
      debugPrint('Error removing judge: $e');
      rethrow;
    }
  }

  /// Validate all case assignments for referential integrity
  Future<List<String>> validateCaseAssignments(String caseId) async {
    final violations = <String>[];

    try {
      final caseModel = await _caseRepository.getById(caseId);
      if (caseModel == null) {
        violations.add('Case not found: $caseId');
        return violations;
      }

      // Validate petitioner lawyer
      if (caseModel.petitioner.lawyerId.isNotEmpty) {
        try {
          await _validateUserRole(
            caseModel.petitioner.lawyerId,
            UserRole.lawyer,
          );
        } catch (e) {
          violations.add(
            'Invalid petitioner lawyer: ${caseModel.petitioner.lawyerId} - $e',
          );
        }
      }

      // Validate respondent lawyer
      if (caseModel.respondent.lawyerId != null &&
          caseModel.respondent.lawyerId!.isNotEmpty) {
        try {
          await _validateUserRole(
            caseModel.respondent.lawyerId!,
            UserRole.lawyer,
          );
        } catch (e) {
          violations.add(
            'Invalid respondent lawyer: ${caseModel.respondent.lawyerId} - $e',
          );
        }
      }

      // Validate assigned judge
      if (caseModel.assignedJudgeId != null &&
          caseModel.assignedJudgeId!.isNotEmpty) {
        try {
          await _validateUserRole(caseModel.assignedJudgeId!, UserRole.judge);
          await _validateJudgeCourtAssignment(
            caseModel.assignedJudgeId!,
            caseModel.courtId,
          );
        } catch (e) {
          violations.add(
            'Invalid assigned judge: ${caseModel.assignedJudgeId} - $e',
          );
        }
      }

      // Validate courtroom assignment
      if (caseModel.assignedJudgeId != null &&
          caseModel.courtroom != null &&
          caseModel.assignedJudgeId!.isNotEmpty &&
          caseModel.courtroom!.isNotEmpty) {
        try {
          await _validateJudgeCourtroomAssignment(
            caseModel.assignedJudgeId!,
            caseModel.courtroom!,
          );
        } catch (e) {
          violations.add(
            'Invalid courtroom assignment: ${caseModel.courtroom} - $e',
          );
        }
      }
    } catch (e) {
      violations.add('Error validating case assignments: $e');
    }

    return violations;
  }

  /// Get all cases assigned to a lawyer
  Future<List<CaseModel>> getCasesForLawyer(String lawyerId) async {
    try {
      // Validate lawyer exists
      await _validateUserRole(lawyerId, UserRole.lawyer);

      return await _caseRepository.getCasesByLawyer(lawyerId);
    } catch (e) {
      debugPrint('Error getting cases for lawyer: $e');
      rethrow;
    }
  }

  /// Get all cases assigned to a judge
  Future<List<CaseModel>> getCasesForJudge(String judgeId) async {
    try {
      // Validate judge exists
      await _validateUserRole(judgeId, UserRole.judge);

      return await _caseRepository.getCasesByJudge(judgeId);
    } catch (e) {
      debugPrint('Error getting cases for judge: $e');
      rethrow;
    }
  }

  /// Get available judges for a court
  Future<List<UserProfile>> getAvailableJudges(String courtId) async {
    try {
      return await _userRepository.getJudgesByCourt(courtId);
    } catch (e) {
      debugPrint('Error getting available judges: $e');
      rethrow;
    }
  }

  /// Get available lawyers
  Future<List<UserProfile>> getAvailableLawyers() async {
    try {
      return await _userRepository.getUsersByRole(UserRole.lawyer);
    } catch (e) {
      debugPrint('Error getting available lawyers: $e');
      rethrow;
    }
  }

  /// Validate user exists and has the correct role
  Future<void> _validateUserRole(String userId, UserRole expectedRole) async {
    final user = await _userRepository.getById(userId);

    if (user == null) {
      throw ReferentialIntegrityException('User not found: $userId');
    }

    if (!user.isActive) {
      throw RoleValidationException('User is not active: $userId');
    }

    if (user.role != expectedRole) {
      throw RoleValidationException(
        'User $userId has role ${user.role.name}, expected ${expectedRole.name}',
      );
    }

    // Validate role-specific profile exists
    switch (expectedRole) {
      case UserRole.lawyer:
        if (user.lawyerProfile == null || !user.lawyerProfile!.isValid()) {
          throw RoleValidationException(
            'Invalid lawyer profile for user: $userId',
          );
        }
        break;
      case UserRole.judge:
        if (user.judgeProfile == null || !user.judgeProfile!.isValid()) {
          throw RoleValidationException(
            'Invalid judge profile for user: $userId',
          );
        }
        break;
      case UserRole.courtMaster:
        if (user.courtMasterProfile == null ||
            !user.courtMasterProfile!.isValid()) {
          throw RoleValidationException(
            'Invalid court master profile for user: $userId',
          );
        }
        break;
    }
  }

  /// Validate judge is assigned to the specified court
  Future<void> _validateJudgeCourtAssignment(
    String judgeId,
    String courtId,
  ) async {
    final judge = await _userRepository.getById(judgeId);

    if (judge == null || judge.judgeProfile == null) {
      throw ReferentialIntegrityException(
        'Judge not found or invalid profile: $judgeId',
      );
    }

    if (judge.judgeProfile!.courtId != courtId) {
      throw ReferentialIntegrityException(
        'Judge $judgeId is assigned to court ${judge.judgeProfile!.courtId}, not $courtId',
      );
    }
  }

  /// Validate judge has access to the specified courtroom
  Future<void> _validateJudgeCourtroomAssignment(
    String judgeId,
    String courtroom,
  ) async {
    final judge = await _userRepository.getById(judgeId);

    if (judge == null || judge.judgeProfile == null) {
      throw ReferentialIntegrityException(
        'Judge not found or invalid profile: $judgeId',
      );
    }

    if (!judge.judgeProfile!.assignedCourtrooms.contains(courtroom)) {
      throw ReferentialIntegrityException(
        'Judge $judgeId is not assigned to courtroom $courtroom',
      );
    }
  }

  /// Bulk validate all case assignments in the system
  Future<Map<String, List<String>>> validateAllCaseAssignments() async {
    final allViolations = <String, List<String>>{};

    try {
      final allCases = await _caseRepository.getAll();

      for (final caseModel in allCases) {
        final violations = await validateCaseAssignments(caseModel.caseId);
        if (violations.isNotEmpty) {
          allViolations[caseModel.caseId] = violations;
        }
      }

      debugPrint(
        'Validation completed: ${allViolations.length} cases with violations',
      );
    } catch (e) {
      debugPrint('Error during bulk validation: $e');
      rethrow;
    }

    return allViolations;
  }

  /// Get assignment statistics
  Future<Map<String, dynamic>> getAssignmentStatistics() async {
    try {
      final allCases = await _caseRepository.getAll();
      final stats = <String, dynamic>{};

      // Count cases with assignments
      stats['total_cases'] = allCases.length;
      stats['cases_with_petitioner_lawyer'] = allCases
          .where((c) => c.petitioner.lawyerId.isNotEmpty)
          .length;
      stats['cases_with_respondent_lawyer'] = allCases
          .where(
            (c) =>
                c.respondent.lawyerId != null &&
                c.respondent.lawyerId!.isNotEmpty,
          )
          .length;
      stats['cases_with_assigned_judge'] = allCases
          .where(
            (c) => c.assignedJudgeId != null && c.assignedJudgeId!.isNotEmpty,
          )
          .length;
      stats['cases_with_courtroom'] = allCases
          .where((c) => c.courtroom != null && c.courtroom!.isNotEmpty)
          .length;

      // Calculate percentages
      if (allCases.isNotEmpty) {
        stats['petitioner_lawyer_percentage'] =
            (stats['cases_with_petitioner_lawyer'] / allCases.length * 100)
                .round();
        stats['respondent_lawyer_percentage'] =
            (stats['cases_with_respondent_lawyer'] / allCases.length * 100)
                .round();
        stats['judge_assignment_percentage'] =
            (stats['cases_with_assigned_judge'] / allCases.length * 100)
                .round();
        stats['courtroom_assignment_percentage'] =
            (stats['cases_with_courtroom'] / allCases.length * 100).round();
      }

      return stats;
    } catch (e) {
      debugPrint('Error getting assignment statistics: $e');
      rethrow;
    }
  }
}

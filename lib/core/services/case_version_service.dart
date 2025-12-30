import 'package:flutter/foundation.dart';
import '../models/case_models.dart';
import '../models/case_version_models.dart';
import '../repositories/case_repository.dart';
import '../repositories/case_version_repository.dart';

/// Service for managing case versions and audit trails
class CaseVersionService {
  final CaseRepository _caseRepository;
  final CaseVersionRepository _versionRepository;
  final CaseAuditRepository _auditRepository;

  CaseVersionService({
    CaseRepository? caseRepository,
    CaseVersionRepository? versionRepository,
    CaseAuditRepository? auditRepository,
  }) : _caseRepository = caseRepository ?? CaseRepository(),
       _versionRepository = versionRepository ?? CaseVersionRepository(),
       _auditRepository = auditRepository ?? CaseAuditRepository();

  /// Create a new case with initial version and audit log
  Future<String> createCaseWithVersioning(
    CaseModel caseModel,
    String createdBy,
  ) async {
    try {
      // Create the case
      final caseId = await _caseRepository.createCase(caseModel);

      // Create initial version
      await _versionRepository.createVersion(
        caseId,
        caseModel.copyWith(caseId: caseId),
        createdBy,
        changeReason: 'Initial case creation',
      );

      // Log audit entry
      await _auditRepository.logAudit(
        caseId,
        AuditActionType.created,
        createdBy,
        description: 'Case created: ${caseModel.caseTitle}',
        newValues: caseModel.toFirestore(),
      );

      debugPrint('Case created with versioning: $caseId');
      return caseId;
    } catch (e) {
      debugPrint('Error creating case with versioning: $e');
      rethrow;
    }
  }

  /// Update a case with version tracking and audit logging
  Future<void> updateCaseWithVersioning(
    String caseId,
    CaseModel updatedCase,
    String updatedBy, {
    String? changeReason,
  }) async {
    try {
      // Get current case data
      final currentCase = await _caseRepository.getById(caseId);
      if (currentCase == null) {
        throw ArgumentError('Case not found: $caseId');
      }

      // Compare old and new data
      final oldData = currentCase.toFirestore();
      final newData = updatedCase.toFirestore();
      final changedFields = _getChangedFields(oldData, newData);

      if (changedFields.isEmpty) {
        debugPrint('No changes detected for case $caseId');
        return;
      }

      // Update the case
      await _caseRepository.update(caseId, updatedCase);

      // Create new version
      await _versionRepository.createVersion(
        caseId,
        updatedCase,
        updatedBy,
        changeReason: changeReason ?? 'Case updated',
        changedFields: changedFields,
      );

      // Log audit entry
      await _auditRepository.logAudit(
        caseId,
        AuditActionType.updated,
        updatedBy,
        description: changeReason ?? 'Case updated',
        oldValues: oldData,
        newValues: newData,
      );

      debugPrint('Case updated with versioning: $caseId');
    } catch (e) {
      debugPrint('Error updating case with versioning: $e');
      rethrow;
    }
  }

  /// Update case status with version tracking
  Future<void> updateCaseStatusWithVersioning(
    String caseId,
    CaseStatus newStatus,
    String updatedBy, {
    String? reason,
  }) async {
    try {
      // Get current case
      final currentCase = await _caseRepository.getById(caseId);
      if (currentCase == null) {
        throw ArgumentError('Case not found: $caseId');
      }

      final oldStatus = currentCase.status;

      // Update status
      await _caseRepository.updateCaseStatus(caseId, newStatus);

      // Get updated case for versioning
      final updatedCase = currentCase.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        lastModifiedBy: updatedBy,
      );

      // Create new version
      await _versionRepository.createVersion(
        caseId,
        updatedCase,
        updatedBy,
        changeReason:
            reason ??
            'Status changed from ${oldStatus.name} to ${newStatus.name}',
        changedFields: {
          'status': {
            'old': oldStatus.toFirestore(),
            'new': newStatus.toFirestore(),
          },
        },
      );

      // Log audit entry
      await _auditRepository.logAudit(
        caseId,
        AuditActionType.statusChanged,
        updatedBy,
        description:
            reason ??
            'Status changed from ${oldStatus.name} to ${newStatus.name}',
        oldValues: {'status': oldStatus.toFirestore()},
        newValues: {'status': newStatus.toFirestore()},
      );

      debugPrint(
        'Case status updated with versioning: $caseId ($oldStatus -> $newStatus)',
      );
    } catch (e) {
      debugPrint('Error updating case status with versioning: $e');
      rethrow;
    }
  }

  /// Assign judge with version tracking
  Future<void> assignJudgeWithVersioning(
    String caseId,
    String judgeId,
    String assignedBy, {
    String? reason,
  }) async {
    try {
      // Get current case
      final currentCase = await _caseRepository.getById(caseId);
      if (currentCase == null) {
        throw ArgumentError('Case not found: $caseId');
      }

      final oldJudgeId = currentCase.assignedJudgeId;

      // Assign judge
      await _caseRepository.assignJudge(caseId, judgeId);

      // Get updated case for versioning
      final updatedCase = currentCase.copyWith(
        assignedJudgeId: judgeId,
        updatedAt: DateTime.now(),
        lastModifiedBy: assignedBy,
      );

      // Create new version
      await _versionRepository.createVersion(
        caseId,
        updatedCase,
        assignedBy,
        changeReason: reason ?? 'Judge assigned: $judgeId',
        changedFields: {
          'assignedJudgeId': {'old': oldJudgeId, 'new': judgeId},
        },
      );

      // Log audit entry
      await _auditRepository.logAudit(
        caseId,
        AuditActionType.judgeAssigned,
        assignedBy,
        description: reason ?? 'Judge assigned: $judgeId',
        oldValues: {'assignedJudgeId': oldJudgeId},
        newValues: {'assignedJudgeId': judgeId},
      );

      debugPrint('Judge assigned with versioning: $caseId -> $judgeId');
    } catch (e) {
      debugPrint('Error assigning judge with versioning: $e');
      rethrow;
    }
  }

  /// Rollback case to a previous version
  Future<void> rollbackToVersion(
    String caseId,
    int versionNumber,
    String performedBy, {
    String? reason,
  }) async {
    try {
      // Get the target version
      final targetVersion = await _versionRepository.getCaseVersion(
        caseId,
        versionNumber,
      );
      if (targetVersion == null) {
        throw ArgumentError(
          'Version $versionNumber not found for case $caseId',
        );
      }

      // Get current case for comparison
      final currentCase = await _caseRepository.getById(caseId);
      if (currentCase == null) {
        throw ArgumentError('Case not found: $caseId');
      }

      // Update case with rollback data
      final rollbackCase = targetVersion.caseData.copyWith(
        updatedAt: DateTime.now(),
        lastModifiedBy: performedBy,
      );

      await _caseRepository.update(caseId, rollbackCase);

      // Create new version for the rollback
      await _versionRepository.createVersion(
        caseId,
        rollbackCase,
        performedBy,
        changeReason: reason ?? 'Rolled back to version $versionNumber',
      );

      // Log audit entry
      await _auditRepository.logAudit(
        caseId,
        AuditActionType.updated,
        performedBy,
        description: reason ?? 'Rolled back to version $versionNumber',
        oldValues: currentCase.toFirestore(),
        newValues: rollbackCase.toFirestore(),
      );

      debugPrint('Case rolled back to version $versionNumber: $caseId');
    } catch (e) {
      debugPrint('Error rolling back case: $e');
      rethrow;
    }
  }

  /// Get case version history
  Future<List<CaseVersion>> getCaseVersionHistory(String caseId) async {
    try {
      return await _versionRepository.getVersionsForCase(caseId);
    } catch (e) {
      debugPrint('Error getting case version history: $e');
      rethrow;
    }
  }

  /// Get case audit trail
  Future<List<CaseAuditLog>> getCaseAuditTrail(String caseId) async {
    try {
      return await _auditRepository.getAuditLogsForCase(caseId);
    } catch (e) {
      debugPrint('Error getting case audit trail: $e');
      rethrow;
    }
  }

  /// Get specific case version
  Future<CaseVersion?> getCaseVersion(String caseId, int versionNumber) async {
    try {
      return await _versionRepository.getCaseVersion(caseId, versionNumber);
    } catch (e) {
      debugPrint('Error getting case version: $e');
      rethrow;
    }
  }

  /// Compare two versions
  Map<String, dynamic> compareVersions(
    CaseVersion oldVersion,
    CaseVersion newVersion,
  ) {
    return _versionRepository.compareVersions(oldVersion, newVersion);
  }

  /// Stream case version history
  Stream<List<CaseVersion>> streamCaseVersionHistory(String caseId) {
    return _versionRepository.streamVersionsForCase(caseId);
  }

  /// Stream case audit trail
  Stream<List<CaseAuditLog>> streamCaseAuditTrail(String caseId) {
    return _auditRepository.streamAuditLogsForCase(caseId);
  }

  /// Clean up old versions and audit logs
  Future<void> cleanupOldData({
    int keepVersions = 10,
    int keepAuditDays = 365,
  }) async {
    try {
      // Get all cases to cleanup their versions
      final allCases = await _caseRepository.getAll();

      for (final caseModel in allCases) {
        await _versionRepository.cleanupOldVersions(
          caseModel.caseId,
          keepVersions: keepVersions,
        );
      }

      // Cleanup old audit logs
      await _auditRepository.cleanupOldLogs(keepDays: keepAuditDays);

      debugPrint(
        'Cleanup completed: kept $keepVersions versions and $keepAuditDays days of audit logs',
      );
    } catch (e) {
      debugPrint('Error during cleanup: $e');
      rethrow;
    }
  }

  /// Helper method to get changed fields between two data maps
  Map<String, dynamic> _getChangedFields(
    Map<String, dynamic> oldData,
    Map<String, dynamic> newData,
  ) {
    final changes = <String, dynamic>{};

    // Compare all fields in new data
    for (final key in newData.keys) {
      if (oldData[key] != newData[key]) {
        changes[key] = {'old': oldData[key], 'new': newData[key]};
      }
    }

    // Check for removed fields
    for (final key in oldData.keys) {
      if (!newData.containsKey(key)) {
        changes[key] = {'old': oldData[key], 'new': null};
      }
    }

    return changes;
  }
}

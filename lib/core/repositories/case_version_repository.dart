import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/case_models.dart';
import '../models/case_version_models.dart';
import 'base_repository.dart';

/// Repository for managing case version history
class CaseVersionRepository extends BaseRepository<CaseVersion> {
  @override
  String get collectionName => 'case_versions';

  @override
  CaseVersion fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return CaseVersion.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(CaseVersion item) {
    return item.toFirestore();
  }

  /// Create a new version of a case
  Future<String> createVersion(
    String caseId,
    CaseModel caseData,
    String createdBy, {
    String? changeReason,
    Map<String, dynamic>? changedFields,
  }) async {
    try {
      // Get the latest version number for this case
      final latestVersion = await getLatestVersionNumber(caseId);
      final newVersionNumber = latestVersion + 1;

      final version = CaseVersion(
        versionId: '', // Will be set by Firestore
        caseId: caseId,
        versionNumber: newVersionNumber,
        caseData: caseData,
        createdAt: DateTime.now(),
        createdBy: createdBy,
        changeReason: changeReason,
        changedFields: changedFields,
      );

      final versionId = await create(version);
      debugPrint(
        'Case version created: $versionId for case $caseId (v$newVersionNumber)',
      );
      return versionId;
    } catch (e) {
      debugPrint('Error creating case version: $e');
      rethrow;
    }
  }

  /// Get latest version number for a case
  Future<int> getLatestVersionNumber(String caseId) async {
    try {
      final querySnapshot = await collection
          .where('caseId', isEqualTo: caseId)
          .orderBy('versionNumber', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 0; // No versions exist yet
      }

      final latestVersion = fromFirestore(querySnapshot.docs.first);
      return latestVersion.versionNumber;
    } catch (e) {
      debugPrint('Error getting latest version number: $e');
      return 0;
    }
  }

  /// Get all versions for a case
  Future<List<CaseVersion>> getVersionsForCase(String caseId) async {
    try {
      final querySnapshot = await collection
          .where('caseId', isEqualTo: caseId)
          .orderBy('versionNumber', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting versions for case: $e');
      rethrow;
    }
  }

  /// Get specific version of a case
  Future<CaseVersion?> getCaseVersion(String caseId, int versionNumber) async {
    try {
      final querySnapshot = await collection
          .where('caseId', isEqualTo: caseId)
          .where('versionNumber', isEqualTo: versionNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      debugPrint('Error getting case version: $e');
      rethrow;
    }
  }

  /// Get latest version of a case
  Future<CaseVersion?> getLatestVersion(String caseId) async {
    try {
      final querySnapshot = await collection
          .where('caseId', isEqualTo: caseId)
          .orderBy('versionNumber', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      debugPrint('Error getting latest version: $e');
      rethrow;
    }
  }

  /// Compare two versions and get changed fields
  Map<String, dynamic> compareVersions(
    CaseVersion oldVersion,
    CaseVersion newVersion,
  ) {
    final oldData = oldVersion.caseData.toFirestore();
    final newData = newVersion.caseData.toFirestore();
    final changes = <String, dynamic>{};

    // Compare all fields
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

  /// Stream versions for a case
  Stream<List<CaseVersion>> streamVersionsForCase(String caseId) {
    return collection
        .where('caseId', isEqualTo: caseId)
        .orderBy('versionNumber', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList(),
        );
  }

  /// Delete old versions (keep only latest N versions)
  Future<void> cleanupOldVersions(
    String caseId, {
    int keepVersions = 10,
  }) async {
    try {
      final versions = await getVersionsForCase(caseId);

      if (versions.length <= keepVersions) {
        return; // Nothing to cleanup
      }

      final versionsToDelete = versions.skip(keepVersions).toList();
      final batch = this.batch;

      for (final version in versionsToDelete) {
        batch.delete(collection.doc(version.versionId));
      }

      await commitBatch(batch);
      debugPrint(
        'Cleaned up ${versionsToDelete.length} old versions for case $caseId',
      );
    } catch (e) {
      debugPrint('Error cleaning up old versions: $e');
      rethrow;
    }
  }
}

/// Repository for managing case audit logs
class CaseAuditRepository extends BaseRepository<CaseAuditLog> {
  @override
  String get collectionName => 'case_audit_logs';

  @override
  CaseAuditLog fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return CaseAuditLog.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(CaseAuditLog item) {
    return item.toFirestore();
  }

  /// Log an audit entry
  Future<String> logAudit(
    String caseId,
    AuditActionType actionType,
    String performedBy, {
    String? description,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      final auditLog = CaseAuditLog(
        auditId: '', // Will be set by Firestore
        caseId: caseId,
        actionType: actionType,
        performedBy: performedBy,
        timestamp: DateTime.now(),
        description: description,
        oldValues: oldValues,
        newValues: newValues,
        ipAddress: ipAddress,
        userAgent: userAgent,
      );

      final auditId = await create(auditLog);
      debugPrint('Audit log created: $auditId for case $caseId');
      return auditId;
    } catch (e) {
      debugPrint('Error creating audit log: $e');
      rethrow;
    }
  }

  /// Get audit logs for a case
  Future<List<CaseAuditLog>> getAuditLogsForCase(String caseId) async {
    try {
      final querySnapshot = await collection
          .where('caseId', isEqualTo: caseId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting audit logs for case: $e');
      rethrow;
    }
  }

  /// Get audit logs by user
  Future<List<CaseAuditLog>> getAuditLogsByUser(String userId) async {
    try {
      final querySnapshot = await collection
          .where('performedBy', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting audit logs by user: $e');
      rethrow;
    }
  }

  /// Get audit logs by action type
  Future<List<CaseAuditLog>> getAuditLogsByAction(
    AuditActionType actionType,
  ) async {
    try {
      final querySnapshot = await collection
          .where('actionType', isEqualTo: actionType.toFirestore())
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting audit logs by action: $e');
      rethrow;
    }
  }

  /// Get audit logs within date range
  Future<List<CaseAuditLog>> getAuditLogsInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await collection
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'timestamp',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          )
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting audit logs in date range: $e');
      rethrow;
    }
  }

  /// Stream audit logs for a case
  Stream<List<CaseAuditLog>> streamAuditLogsForCase(String caseId) {
    return collection
        .where('caseId', isEqualTo: caseId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList(),
        );
  }

  /// Get audit statistics
  Future<Map<String, int>> getAuditStatistics() async {
    try {
      final allLogs = await getAll();
      final stats = <String, int>{};

      // Count by action type
      for (final actionType in AuditActionType.values) {
        stats['${actionType.name}_count'] = allLogs
            .where((log) => log.actionType == actionType)
            .length;
      }

      // Total logs
      stats['total_logs'] = allLogs.length;

      return stats;
    } catch (e) {
      debugPrint('Error getting audit statistics: $e');
      rethrow;
    }
  }

  /// Clean up old audit logs (keep only logs from last N days)
  Future<void> cleanupOldLogs({int keepDays = 365}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
      final querySnapshot = await collection
          .where('timestamp', isLessThan: cutoffDate.millisecondsSinceEpoch)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return; // Nothing to cleanup
      }

      final batch = this.batch;
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await commitBatch(batch);
      debugPrint('Cleaned up ${querySnapshot.docs.length} old audit logs');
    } catch (e) {
      debugPrint('Error cleaning up old audit logs: $e');
      rethrow;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/case_models.dart';
import 'base_repository.dart';

/// Repository for managing case data in Firestore
class CaseRepository extends BaseRepository<CaseModel> {
  @override
  String get collectionName => 'cases';

  @override
  CaseModel fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return CaseModel.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(CaseModel item) {
    return item.toFirestore();
  }

  /// Create a new case with validation
  Future<String> createCase(CaseModel caseModel) async {
    try {
      // Validate case data before creating
      if (!caseModel.isValid()) {
        throw ArgumentError('Invalid case data provided');
      }

      // Ensure case has unique case number
      final existingCase = await getCaseByCaseNumber(caseModel.caseNumber);
      if (existingCase != null) {
        throw ArgumentError(
          'Case number ${caseModel.caseNumber} already exists',
        );
      }

      // Create the case
      final caseId = await create(caseModel);

      debugPrint('Case created successfully with ID: $caseId');
      return caseId;
    } catch (e) {
      debugPrint('Error creating case: $e');
      rethrow;
    }
  }

  /// Update case status with validation
  Future<void> updateCaseStatus(String caseId, CaseStatus newStatus) async {
    try {
      // Validate status transition
      final currentCase = await getById(caseId);
      if (currentCase == null) {
        throw ArgumentError('Case not found: $caseId');
      }

      if (!_isValidStatusTransition(currentCase.status, newStatus)) {
        throw ArgumentError(
          'Invalid status transition from ${currentCase.status} to $newStatus',
        );
      }

      // Update status and timestamp
      await updateFields(caseId, {
        'status': newStatus.toFirestore(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      debugPrint('Case $caseId status updated to $newStatus');
    } catch (e) {
      debugPrint('Error updating case status: $e');
      rethrow;
    }
  }

  /// Assign judge to case
  Future<void> assignJudge(String caseId, String judgeId) async {
    try {
      await updateFields(caseId, {
        'assignedJudgeId': judgeId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      debugPrint('Judge $judgeId assigned to case $caseId');
    } catch (e) {
      debugPrint('Error assigning judge to case: $e');
      rethrow;
    }
  }

  /// Assign courtroom to case
  Future<void> assignCourtroom(String caseId, String courtroom) async {
    try {
      await updateFields(caseId, {
        'courtroom': courtroom,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      debugPrint('Courtroom $courtroom assigned to case $caseId');
    } catch (e) {
      debugPrint('Error assigning courtroom to case: $e');
      rethrow;
    }
  }

  /// Update hearing count
  Future<void> updateHearingCount(String caseId, int newCount) async {
    try {
      await updateFields(caseId, {
        'hearingCount': newCount,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      debugPrint('Hearing count updated for case $caseId: $newCount');
    } catch (e) {
      debugPrint('Error updating hearing count: $e');
      rethrow;
    }
  }

  /// Update next hearing date
  Future<void> updateNextHearingDate(
    String caseId,
    DateTime? nextHearingDate,
  ) async {
    try {
      await updateFields(caseId, {
        'nextHearingDate': nextHearingDate?.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      debugPrint(
        'Next hearing date updated for case $caseId: $nextHearingDate',
      );
    } catch (e) {
      debugPrint('Error updating next hearing date: $e');
      rethrow;
    }
  }

  /// Get case by case number
  Future<CaseModel?> getCaseByCaseNumber(String caseNumber) async {
    try {
      final cases = await getWhere('caseNumber', caseNumber);
      return cases.isNotEmpty ? cases.first : null;
    } catch (e) {
      debugPrint('Error getting case by case number: $e');
      rethrow;
    }
  }

  /// Get cases by status
  Future<List<CaseModel>> getCasesByStatus(CaseStatus status) async {
    try {
      return await getWhere('status', status.toFirestore());
    } catch (e) {
      debugPrint('Error getting cases by status: $e');
      rethrow;
    }
  }

  /// Get cases by lawyer ID
  Future<List<CaseModel>> getCasesByLawyer(String lawyerId) async {
    try {
      final petitionerCases = await collection
          .where('petitioner.lawyerId', isEqualTo: lawyerId)
          .get();

      final respondentCases = await collection
          .where('respondent.lawyerId', isEqualTo: lawyerId)
          .get();

      final allCases = <CaseModel>[];

      // Add petitioner cases
      for (final doc in petitionerCases.docs) {
        allCases.add(fromFirestore(doc));
      }

      // Add respondent cases (avoid duplicates)
      for (final doc in respondentCases.docs) {
        if (!allCases.any((c) => c.caseId == doc.id)) {
          allCases.add(fromFirestore(doc));
        }
      }

      return allCases;
    } catch (e) {
      debugPrint('Error getting cases by lawyer: $e');
      rethrow;
    }
  }

  /// Get cases by judge ID
  Future<List<CaseModel>> getCasesByJudge(String judgeId) async {
    try {
      return await getWhere('assignedJudgeId', judgeId);
    } catch (e) {
      debugPrint('Error getting cases by judge: $e');
      rethrow;
    }
  }

  /// Get cases by court ID
  Future<List<CaseModel>> getCasesByCourt(String courtId) async {
    try {
      return await getWhere('courtId', courtId);
    } catch (e) {
      debugPrint('Error getting cases by court: $e');
      rethrow;
    }
  }

  /// Get cases by priority
  Future<List<CaseModel>> getCasesByPriority(CasePriority priority) async {
    try {
      return await getWhere('priority', priority.toFirestore());
    } catch (e) {
      debugPrint('Error getting cases by priority: $e');
      rethrow;
    }
  }

  /// Get cases filed within date range
  Future<List<CaseModel>> getCasesInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await collection
          .where(
            'filingDate',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
          )
          .where(
            'filingDate',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
          )
          .get();

      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting cases in date range: $e');
      rethrow;
    }
  }

  /// Get cases with specific tags
  Future<List<CaseModel>> getCasesWithTag(String tag) async {
    try {
      final querySnapshot = await collection
          .where('tags', arrayContains: tag)
          .get();

      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting cases with tag: $e');
      rethrow;
    }
  }

  /// Stream cases by status
  Stream<List<CaseModel>> streamCasesByStatus(CaseStatus status) {
    return streamWhere('status', status.toFirestore());
  }

  /// Stream cases by lawyer ID
  Stream<List<CaseModel>> streamCasesByLawyer(String lawyerId) {
    // Note: This is a simplified version. For production, you might want to
    // combine multiple streams for petitioner and respondent cases
    return collection
        .where('petitioner.lawyerId', isEqualTo: lawyerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList(),
        );
  }

  /// Stream cases by judge ID
  Stream<List<CaseModel>> streamCasesByJudge(String judgeId) {
    return streamWhere('assignedJudgeId', judgeId);
  }

  /// Stream cases by court ID
  Stream<List<CaseModel>> streamCasesByCourt(String courtId) {
    return streamWhere('courtId', courtId);
  }

  /// Validate case status transition
  bool _isValidStatusTransition(
    CaseStatus currentStatus,
    CaseStatus newStatus,
  ) {
    // Define valid status transitions
    const validTransitions = {
      CaseStatus.filed: [CaseStatus.underScrutiny, CaseStatus.defective],
      CaseStatus.underScrutiny: [CaseStatus.listed, CaseStatus.defective],
      CaseStatus.listed: [CaseStatus.running, CaseStatus.adjourned],
      CaseStatus.running: [CaseStatus.disposed, CaseStatus.adjourned],
      CaseStatus.adjourned: [CaseStatus.listed, CaseStatus.running],
      CaseStatus.defective: [CaseStatus.filed, CaseStatus.underScrutiny],
      CaseStatus.disposed: [], // Final status, no transitions allowed
    };

    final allowedTransitions = validTransitions[currentStatus] ?? [];
    return allowedTransitions.contains(newStatus);
  }

  /// Get case statistics
  Future<Map<String, int>> getCaseStatistics() async {
    try {
      final allCases = await getAll();
      final stats = <String, int>{};

      // Count by status
      for (final status in CaseStatus.values) {
        stats['${status.name}_count'] = allCases
            .where((c) => c.status == status)
            .length;
      }

      // Count by priority
      for (final priority in CasePriority.values) {
        stats['${priority.name}_priority_count'] = allCases
            .where((c) => c.priority == priority)
            .length;
      }

      // Total cases
      stats['total_cases'] = allCases.length;

      return stats;
    } catch (e) {
      debugPrint('Error getting case statistics: $e');
      rethrow;
    }
  }

  /// Search cases by text (case number, title, or petitioner name)
  Future<List<CaseModel>> searchCases(String searchText) async {
    try {
      final allCases = await getAll();
      final searchLower = searchText.toLowerCase();

      return allCases.where((caseModel) {
        return caseModel.caseNumber.toLowerCase().contains(searchLower) ||
            caseModel.caseTitle.toLowerCase().contains(searchLower) ||
            caseModel.petitioner.name.toLowerCase().contains(searchLower) ||
            caseModel.respondent.name.toLowerCase().contains(searchLower);
      }).toList();
    } catch (e) {
      debugPrint('Error searching cases: $e');
      rethrow;
    }
  }

  /// Bulk update case status
  Future<void> bulkUpdateStatus(
    List<String> caseIds,
    CaseStatus newStatus,
  ) async {
    try {
      final batch = this.batch;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      for (final caseId in caseIds) {
        batch.update(collection.doc(caseId), {
          'status': newStatus.toFirestore(),
          'updatedAt': timestamp,
        });
      }

      await commitBatch(batch);
      debugPrint('Bulk status update completed for ${caseIds.length} cases');
    } catch (e) {
      debugPrint('Error in bulk status update: $e');
      rethrow;
    }
  }
}

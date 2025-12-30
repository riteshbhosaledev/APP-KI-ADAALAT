import 'package:cloud_firestore/cloud_firestore.dart';
import 'case_models.dart';

/// Enum for audit action types
enum AuditActionType {
  created,
  updated,
  statusChanged,
  judgeAssigned,
  courtroomAssigned,
  documentAdded,
  documentRemoved,
  hearingScheduled,
  hearingCompleted,
  deleted;

  /// Convert enum to string for Firestore storage
  String toFirestore() {
    switch (this) {
      case AuditActionType.created:
        return 'created';
      case AuditActionType.updated:
        return 'updated';
      case AuditActionType.statusChanged:
        return 'status_changed';
      case AuditActionType.judgeAssigned:
        return 'judge_assigned';
      case AuditActionType.courtroomAssigned:
        return 'courtroom_assigned';
      case AuditActionType.documentAdded:
        return 'document_added';
      case AuditActionType.documentRemoved:
        return 'document_removed';
      case AuditActionType.hearingScheduled:
        return 'hearing_scheduled';
      case AuditActionType.hearingCompleted:
        return 'hearing_completed';
      case AuditActionType.deleted:
        return 'deleted';
    }
  }

  /// Create enum from Firestore string
  static AuditActionType fromFirestore(String value) {
    switch (value) {
      case 'created':
        return AuditActionType.created;
      case 'updated':
        return AuditActionType.updated;
      case 'status_changed':
        return AuditActionType.statusChanged;
      case 'judge_assigned':
        return AuditActionType.judgeAssigned;
      case 'courtroom_assigned':
        return AuditActionType.courtroomAssigned;
      case 'document_added':
        return AuditActionType.documentAdded;
      case 'document_removed':
        return AuditActionType.documentRemoved;
      case 'hearing_scheduled':
        return AuditActionType.hearingScheduled;
      case 'hearing_completed':
        return AuditActionType.hearingCompleted;
      case 'deleted':
        return AuditActionType.deleted;
      default:
        throw ArgumentError('Invalid audit action type: $value');
    }
  }
}

/// Case version model for tracking changes
class CaseVersion {
  final String versionId;
  final String caseId;
  final int versionNumber;
  final CaseModel caseData;
  final DateTime createdAt;
  final String createdBy;
  final String? changeReason;
  final Map<String, dynamic>? changedFields;

  const CaseVersion({
    required this.versionId,
    required this.caseId,
    required this.versionNumber,
    required this.caseData,
    required this.createdAt,
    required this.createdBy,
    this.changeReason,
    this.changedFields,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'versionId': versionId,
      'caseId': caseId,
      'versionNumber': versionNumber,
      'caseData': caseData.toFirestore(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'createdBy': createdBy,
      'changeReason': changeReason,
      'changedFields': changedFields,
    };
  }

  /// Create from Firestore document
  factory CaseVersion.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return CaseVersion(
      versionId: doc.id,
      caseId: data['caseId'] ?? '',
      versionNumber: data['versionNumber'] ?? 1,
      caseData: CaseModel.fromFirestore(
        // Create a mock document snapshot for the case data
        MockDocumentSnapshot(data['caseData'] ?? {}, data['caseId'] ?? ''),
      ),
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      createdBy: data['createdBy'] ?? '',
      changeReason: data['changeReason'],
      changedFields: data['changedFields'] != null
          ? Map<String, dynamic>.from(data['changedFields'])
          : null,
    );
  }

  /// Create copy with updated values
  CaseVersion copyWith({
    String? versionId,
    String? caseId,
    int? versionNumber,
    CaseModel? caseData,
    DateTime? createdAt,
    String? createdBy,
    String? changeReason,
    Map<String, dynamic>? changedFields,
  }) {
    return CaseVersion(
      versionId: versionId ?? this.versionId,
      caseId: caseId ?? this.caseId,
      versionNumber: versionNumber ?? this.versionNumber,
      caseData: caseData ?? this.caseData,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      changeReason: changeReason ?? this.changeReason,
      changedFields: changedFields ?? this.changedFields,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CaseVersion &&
        other.versionId == versionId &&
        other.caseId == caseId &&
        other.versionNumber == versionNumber &&
        other.caseData == caseData &&
        other.createdAt == createdAt &&
        other.createdBy == createdBy &&
        other.changeReason == changeReason &&
        other.changedFields.toString() == changedFields.toString();
  }

  @override
  int get hashCode {
    return versionId.hashCode ^
        caseId.hashCode ^
        versionNumber.hashCode ^
        caseData.hashCode ^
        createdAt.hashCode ^
        createdBy.hashCode ^
        changeReason.hashCode ^
        changedFields.hashCode;
  }

  @override
  String toString() {
    return 'CaseVersion(versionId: $versionId, caseId: $caseId, versionNumber: $versionNumber)';
  }
}

/// Audit log entry for case modifications
class CaseAuditLog {
  final String auditId;
  final String caseId;
  final AuditActionType actionType;
  final String performedBy;
  final DateTime timestamp;
  final String? description;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final String? ipAddress;
  final String? userAgent;

  const CaseAuditLog({
    required this.auditId,
    required this.caseId,
    required this.actionType,
    required this.performedBy,
    required this.timestamp,
    this.description,
    this.oldValues,
    this.newValues,
    this.ipAddress,
    this.userAgent,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'auditId': auditId,
      'caseId': caseId,
      'actionType': actionType.toFirestore(),
      'performedBy': performedBy,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'description': description,
      'oldValues': oldValues,
      'newValues': newValues,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
    };
  }

  /// Create from Firestore document
  factory CaseAuditLog.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return CaseAuditLog(
      auditId: doc.id,
      caseId: data['caseId'] ?? '',
      actionType: AuditActionType.fromFirestore(
        data['actionType'] ?? 'updated',
      ),
      performedBy: data['performedBy'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
          : DateTime.now(),
      description: data['description'],
      oldValues: data['oldValues'] != null
          ? Map<String, dynamic>.from(data['oldValues'])
          : null,
      newValues: data['newValues'] != null
          ? Map<String, dynamic>.from(data['newValues'])
          : null,
      ipAddress: data['ipAddress'],
      userAgent: data['userAgent'],
    );
  }

  /// Create copy with updated values
  CaseAuditLog copyWith({
    String? auditId,
    String? caseId,
    AuditActionType? actionType,
    String? performedBy,
    DateTime? timestamp,
    String? description,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    String? ipAddress,
    String? userAgent,
  }) {
    return CaseAuditLog(
      auditId: auditId ?? this.auditId,
      caseId: caseId ?? this.caseId,
      actionType: actionType ?? this.actionType,
      performedBy: performedBy ?? this.performedBy,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      oldValues: oldValues ?? this.oldValues,
      newValues: newValues ?? this.newValues,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CaseAuditLog &&
        other.auditId == auditId &&
        other.caseId == caseId &&
        other.actionType == actionType &&
        other.performedBy == performedBy &&
        other.timestamp == timestamp &&
        other.description == description &&
        other.oldValues.toString() == oldValues.toString() &&
        other.newValues.toString() == newValues.toString() &&
        other.ipAddress == ipAddress &&
        other.userAgent == userAgent;
  }

  @override
  int get hashCode {
    return auditId.hashCode ^
        caseId.hashCode ^
        actionType.hashCode ^
        performedBy.hashCode ^
        timestamp.hashCode ^
        description.hashCode ^
        oldValues.hashCode ^
        newValues.hashCode ^
        ipAddress.hashCode ^
        userAgent.hashCode;
  }

  @override
  String toString() {
    return 'CaseAuditLog(auditId: $auditId, caseId: $caseId, actionType: $actionType, performedBy: $performedBy)';
  }
}

/// Mock DocumentSnapshot for testing and internal use
class MockDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  final String _id;

  MockDocumentSnapshot(this._data, this._id);

  @override
  Map<String, dynamic>? data() => _data;

  @override
  String get id => _id;

  @override
  bool get exists => _data.isNotEmpty;

  @override
  DocumentReference<Map<String, dynamic>> get reference =>
      throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  T? get<T extends Object?>(Object field) => throw UnimplementedError();

  @override
  operator [](Object field) => throw UnimplementedError();
}

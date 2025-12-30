import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for case status
enum CaseStatus {
  filed,
  underScrutiny,
  listed,
  running,
  disposed,
  defective,
  adjourned;

  /// Convert enum to string for Firestore storage
  String toFirestore() {
    switch (this) {
      case CaseStatus.filed:
        return 'filed';
      case CaseStatus.underScrutiny:
        return 'under_scrutiny';
      case CaseStatus.listed:
        return 'listed';
      case CaseStatus.running:
        return 'running';
      case CaseStatus.disposed:
        return 'disposed';
      case CaseStatus.defective:
        return 'defective';
      case CaseStatus.adjourned:
        return 'adjourned';
    }
  }

  /// Create enum from Firestore string
  static CaseStatus fromFirestore(String value) {
    switch (value) {
      case 'filed':
        return CaseStatus.filed;
      case 'under_scrutiny':
        return CaseStatus.underScrutiny;
      case 'listed':
        return CaseStatus.listed;
      case 'running':
        return CaseStatus.running;
      case 'disposed':
        return CaseStatus.disposed;
      case 'defective':
        return CaseStatus.defective;
      case 'adjourned':
        return CaseStatus.adjourned;
      default:
        throw ArgumentError('Invalid case status: $value');
    }
  }
}

/// Enum for case priority
enum CasePriority {
  high,
  medium,
  low;

  /// Convert enum to string for Firestore storage
  String toFirestore() {
    switch (this) {
      case CasePriority.high:
        return 'high';
      case CasePriority.medium:
        return 'medium';
      case CasePriority.low:
        return 'low';
    }
  }

  /// Create enum from Firestore string
  static CasePriority fromFirestore(String value) {
    switch (value) {
      case 'high':
        return CasePriority.high;
      case 'medium':
        return CasePriority.medium;
      case 'low':
        return CasePriority.low;
      default:
        throw ArgumentError('Invalid case priority: $value');
    }
  }
}

/// Enum for court fee status
enum CourtFeeStatus {
  paid,
  pending,
  exempted;

  /// Convert enum to string for Firestore storage
  String toFirestore() {
    switch (this) {
      case CourtFeeStatus.paid:
        return 'paid';
      case CourtFeeStatus.pending:
        return 'pending';
      case CourtFeeStatus.exempted:
        return 'exempted';
    }
  }

  /// Create enum from Firestore string
  static CourtFeeStatus fromFirestore(String value) {
    switch (value) {
      case 'paid':
        return CourtFeeStatus.paid;
      case 'pending':
        return CourtFeeStatus.pending;
      case 'exempted':
        return CourtFeeStatus.exempted;
      default:
        throw ArgumentError('Invalid court fee status: $value');
    }
  }
}

/// Court fee information
class CourtFee {
  final double amount;
  final CourtFeeStatus status;
  final String? receiptNumber;

  const CourtFee({
    required this.amount,
    required this.status,
    this.receiptNumber,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'status': status.toFirestore(),
      'receiptNumber': receiptNumber,
    };
  }

  /// Create from Firestore map
  factory CourtFee.fromFirestore(Map<String, dynamic> data) {
    return CourtFee(
      amount: (data['amount'] ?? 0.0).toDouble(),
      status: CourtFeeStatus.fromFirestore(data['status'] ?? 'pending'),
      receiptNumber: data['receiptNumber'],
    );
  }

  /// Create copy with updated values
  CourtFee copyWith({
    double? amount,
    CourtFeeStatus? status,
    String? receiptNumber,
  }) {
    return CourtFee(
      amount: amount ?? this.amount,
      status: status ?? this.status,
      receiptNumber: receiptNumber ?? this.receiptNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourtFee &&
        other.amount == amount &&
        other.status == status &&
        other.receiptNumber == receiptNumber;
  }

  @override
  int get hashCode {
    return amount.hashCode ^ status.hashCode ^ receiptNumber.hashCode;
  }
}

/// Petitioner information
class Petitioner {
  final String name;
  final String address;
  final String? contactInfo;
  final String lawyerId; // reference to lawyer user

  const Petitioner({
    required this.name,
    required this.address,
    this.contactInfo,
    required this.lawyerId,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'contactInfo': contactInfo,
      'lawyerId': lawyerId,
    };
  }

  /// Create from Firestore map
  factory Petitioner.fromFirestore(Map<String, dynamic> data) {
    return Petitioner(
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      contactInfo: data['contactInfo'],
      lawyerId: data['lawyerId'] ?? '',
    );
  }

  /// Validate petitioner data
  bool isValid() {
    return name.isNotEmpty && address.isNotEmpty && lawyerId.isNotEmpty;
  }

  /// Create copy with updated values
  Petitioner copyWith({
    String? name,
    String? address,
    String? contactInfo,
    String? lawyerId,
  }) {
    return Petitioner(
      name: name ?? this.name,
      address: address ?? this.address,
      contactInfo: contactInfo ?? this.contactInfo,
      lawyerId: lawyerId ?? this.lawyerId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Petitioner &&
        other.name == name &&
        other.address == address &&
        other.contactInfo == contactInfo &&
        other.lawyerId == lawyerId;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        address.hashCode ^
        contactInfo.hashCode ^
        lawyerId.hashCode;
  }
}

/// Respondent information
class Respondent {
  final String name;
  final String address;
  final String? contactInfo;
  final String? lawyerId; // reference to lawyer user if represented

  const Respondent({
    required this.name,
    required this.address,
    this.contactInfo,
    this.lawyerId,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'contactInfo': contactInfo,
      'lawyerId': lawyerId,
    };
  }

  /// Create from Firestore map
  factory Respondent.fromFirestore(Map<String, dynamic> data) {
    return Respondent(
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      contactInfo: data['contactInfo'],
      lawyerId: data['lawyerId'],
    );
  }

  /// Validate respondent data
  bool isValid() {
    return name.isNotEmpty && address.isNotEmpty;
  }

  /// Create copy with updated values
  Respondent copyWith({
    String? name,
    String? address,
    String? contactInfo,
    String? lawyerId,
  }) {
    return Respondent(
      name: name ?? this.name,
      address: address ?? this.address,
      contactInfo: contactInfo ?? this.contactInfo,
      lawyerId: lawyerId ?? this.lawyerId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Respondent &&
        other.name == name &&
        other.address == address &&
        other.contactInfo == contactInfo &&
        other.lawyerId == lawyerId;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        address.hashCode ^
        contactInfo.hashCode ^
        lawyerId.hashCode;
  }
}

/// Main case model class
class CaseModel {
  final String caseId;
  final String caseNumber;
  final String caseType;
  final String caseTitle;
  final Petitioner petitioner;
  final Respondent respondent;
  final DateTime filingDate;
  final CaseStatus status;
  final CasePriority priority;
  final List<String> tags;
  final String courtId;
  final String? assignedJudgeId;
  final String? courtroom;
  final List<String> sections;
  final String summary;
  final String reliefSought;
  final String facts;
  final String? affidavitId;
  final String? vakalatnamaNumber;
  final CourtFee courtFee;
  final int hearingCount;
  final DateTime? lastHearingDate;
  final DateTime? nextHearingDate;
  final int estimatedDuration; // in minutes
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String lastModifiedBy;

  const CaseModel({
    required this.caseId,
    required this.caseNumber,
    required this.caseType,
    required this.caseTitle,
    required this.petitioner,
    required this.respondent,
    required this.filingDate,
    required this.status,
    required this.priority,
    required this.tags,
    required this.courtId,
    this.assignedJudgeId,
    this.courtroom,
    required this.sections,
    required this.summary,
    required this.reliefSought,
    required this.facts,
    this.affidavitId,
    this.vakalatnamaNumber,
    required this.courtFee,
    this.hearingCount = 0,
    this.lastHearingDate,
    this.nextHearingDate,
    this.estimatedDuration = 30,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.lastModifiedBy,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'caseId': caseId,
      'caseNumber': caseNumber,
      'caseType': caseType,
      'caseTitle': caseTitle,
      'petitioner': petitioner.toFirestore(),
      'respondent': respondent.toFirestore(),
      'filingDate': filingDate.millisecondsSinceEpoch,
      'status': status.toFirestore(),
      'priority': priority.toFirestore(),
      'tags': tags,
      'courtId': courtId,
      'assignedJudgeId': assignedJudgeId,
      'courtroom': courtroom,
      'sections': sections,
      'summary': summary,
      'reliefSought': reliefSought,
      'facts': facts,
      'affidavitId': affidavitId,
      'vakalatnamaNumber': vakalatnamaNumber,
      'courtFee': courtFee.toFirestore(),
      'hearingCount': hearingCount,
      'lastHearingDate': lastHearingDate?.millisecondsSinceEpoch,
      'nextHearingDate': nextHearingDate?.millisecondsSinceEpoch,
      'estimatedDuration': estimatedDuration,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'createdBy': createdBy,
      'lastModifiedBy': lastModifiedBy,
    };
  }

  /// Create from Firestore document
  factory CaseModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return CaseModel(
      caseId: doc.id,
      caseNumber: data['caseNumber'] ?? '',
      caseType: data['caseType'] ?? '',
      caseTitle: data['caseTitle'] ?? '',
      petitioner: Petitioner.fromFirestore(data['petitioner'] ?? {}),
      respondent: Respondent.fromFirestore(data['respondent'] ?? {}),
      filingDate: data['filingDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['filingDate'])
          : DateTime.now(),
      status: CaseStatus.fromFirestore(data['status'] ?? 'filed'),
      priority: CasePriority.fromFirestore(data['priority'] ?? 'medium'),
      tags: List<String>.from(data['tags'] ?? []),
      courtId: data['courtId'] ?? '',
      assignedJudgeId: data['assignedJudgeId'],
      courtroom: data['courtroom'],
      sections: List<String>.from(data['sections'] ?? []),
      summary: data['summary'] ?? '',
      reliefSought: data['reliefSought'] ?? '',
      facts: data['facts'] ?? '',
      affidavitId: data['affidavitId'],
      vakalatnamaNumber: data['vakalatnamaNumber'],
      courtFee: CourtFee.fromFirestore(data['courtFee'] ?? {}),
      hearingCount: data['hearingCount'] ?? 0,
      lastHearingDate: data['lastHearingDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastHearingDate'])
          : null,
      nextHearingDate: data['nextHearingDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['nextHearingDate'])
          : null,
      estimatedDuration: data['estimatedDuration'] ?? 30,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : DateTime.now(),
      createdBy: data['createdBy'] ?? '',
      lastModifiedBy: data['lastModifiedBy'] ?? '',
    );
  }

  /// Validate case data
  bool isValid() {
    return caseId.isNotEmpty &&
        caseNumber.isNotEmpty &&
        caseType.isNotEmpty &&
        caseTitle.isNotEmpty &&
        petitioner.isValid() &&
        respondent.isValid() &&
        courtId.isNotEmpty &&
        summary.isNotEmpty &&
        reliefSought.isNotEmpty &&
        facts.isNotEmpty &&
        createdBy.isNotEmpty &&
        lastModifiedBy.isNotEmpty;
  }

  /// Check if case has required documents
  bool hasRequiredDocuments() {
    return affidavitId != null && vakalatnamaNumber != null;
  }

  /// Check if case is ready for hearing
  bool isReadyForHearing() {
    return status == CaseStatus.listed &&
        assignedJudgeId != null &&
        courtroom != null &&
        hasRequiredDocuments();
  }

  /// Get case display title
  String get displayTitle {
    return '$caseNumber - $caseTitle';
  }

  /// Create copy with updated values
  CaseModel copyWith({
    String? caseId,
    String? caseNumber,
    String? caseType,
    String? caseTitle,
    Petitioner? petitioner,
    Respondent? respondent,
    DateTime? filingDate,
    CaseStatus? status,
    CasePriority? priority,
    List<String>? tags,
    String? courtId,
    String? assignedJudgeId,
    String? courtroom,
    List<String>? sections,
    String? summary,
    String? reliefSought,
    String? facts,
    String? affidavitId,
    String? vakalatnamaNumber,
    CourtFee? courtFee,
    int? hearingCount,
    DateTime? lastHearingDate,
    DateTime? nextHearingDate,
    int? estimatedDuration,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? lastModifiedBy,
  }) {
    return CaseModel(
      caseId: caseId ?? this.caseId,
      caseNumber: caseNumber ?? this.caseNumber,
      caseType: caseType ?? this.caseType,
      caseTitle: caseTitle ?? this.caseTitle,
      petitioner: petitioner ?? this.petitioner,
      respondent: respondent ?? this.respondent,
      filingDate: filingDate ?? this.filingDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      courtId: courtId ?? this.courtId,
      assignedJudgeId: assignedJudgeId ?? this.assignedJudgeId,
      courtroom: courtroom ?? this.courtroom,
      sections: sections ?? this.sections,
      summary: summary ?? this.summary,
      reliefSought: reliefSought ?? this.reliefSought,
      facts: facts ?? this.facts,
      affidavitId: affidavitId ?? this.affidavitId,
      vakalatnamaNumber: vakalatnamaNumber ?? this.vakalatnamaNumber,
      courtFee: courtFee ?? this.courtFee,
      hearingCount: hearingCount ?? this.hearingCount,
      lastHearingDate: lastHearingDate ?? this.lastHearingDate,
      nextHearingDate: nextHearingDate ?? this.nextHearingDate,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CaseModel &&
        other.caseId == caseId &&
        other.caseNumber == caseNumber &&
        other.caseType == caseType &&
        other.caseTitle == caseTitle &&
        other.petitioner == petitioner &&
        other.respondent == respondent &&
        other.filingDate == filingDate &&
        other.status == status &&
        other.priority == priority &&
        other.tags.toString() == tags.toString() &&
        other.courtId == courtId &&
        other.assignedJudgeId == assignedJudgeId &&
        other.courtroom == courtroom &&
        other.sections.toString() == sections.toString() &&
        other.summary == summary &&
        other.reliefSought == reliefSought &&
        other.facts == facts &&
        other.affidavitId == affidavitId &&
        other.vakalatnamaNumber == vakalatnamaNumber &&
        other.courtFee == courtFee &&
        other.hearingCount == hearingCount &&
        other.lastHearingDate == lastHearingDate &&
        other.nextHearingDate == nextHearingDate &&
        other.estimatedDuration == estimatedDuration &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.createdBy == createdBy &&
        other.lastModifiedBy == lastModifiedBy;
  }

  @override
  int get hashCode {
    return caseId.hashCode ^
        caseNumber.hashCode ^
        caseType.hashCode ^
        caseTitle.hashCode ^
        petitioner.hashCode ^
        respondent.hashCode ^
        filingDate.hashCode ^
        status.hashCode ^
        priority.hashCode ^
        tags.hashCode ^
        courtId.hashCode ^
        assignedJudgeId.hashCode ^
        courtroom.hashCode ^
        sections.hashCode ^
        summary.hashCode ^
        reliefSought.hashCode ^
        facts.hashCode ^
        affidavitId.hashCode ^
        vakalatnamaNumber.hashCode ^
        courtFee.hashCode ^
        hearingCount.hashCode ^
        lastHearingDate.hashCode ^
        nextHearingDate.hashCode ^
        estimatedDuration.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        createdBy.hashCode ^
        lastModifiedBy.hashCode;
  }

  @override
  String toString() {
    return 'CaseModel(caseId: $caseId, caseNumber: $caseNumber, caseTitle: $caseTitle, status: $status)';
  }
}

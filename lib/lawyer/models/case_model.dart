class Case {
  final String id;
  final String caseType;
  final String petitionerName;
  final CaseStatus status;
  final int? itemNumber;
  final String? hearingTime;
  final DateTime filedDate;

  Case({
    required this.id,
    required this.caseType,
    required this.petitionerName,
    required this.status,
    this.itemNumber,
    this.hearingTime,
    required this.filedDate,
  });
}

enum CaseStatus { pending, listed, defective, disposed }

// Mock data
class MockData {
  static List<Case> getMockCases() {
    return [
      Case(
        id: 'BA/2024/12345',
        caseType: 'Bail Application',
        petitionerName: 'Rajesh Kumar vs State of Maharashtra',
        status: CaseStatus.listed,
        itemNumber: 15,
        hearingTime: '11:30 AM',
        filedDate: DateTime(2024, 12, 15),
      ),
      Case(
        id: 'CRL/2024/67890',
        caseType: 'Criminal Revision',
        petitionerName: 'Priya Sharma vs State',
        status: CaseStatus.pending,
        filedDate: DateTime(2024, 12, 20),
      ),
      Case(
        id: 'WP/2024/54321',
        caseType: 'Writ Petition',
        petitionerName: 'Amit Patel vs Municipal Corporation',
        status: CaseStatus.defective,
        filedDate: DateTime(2024, 12, 10),
      ),
      Case(
        id: 'CA/2024/11111',
        caseType: 'Civil Appeal',
        petitionerName: 'Sunita Verma vs Ramesh Verma',
        status: CaseStatus.listed,
        itemNumber: 23,
        hearingTime: '02:15 PM',
        filedDate: DateTime(2024, 12, 5),
      ),
      Case(
        id: 'MA/2024/22222',
        caseType: 'Miscellaneous Application',
        petitionerName: 'Tech Solutions Pvt Ltd vs Commissioner',
        status: CaseStatus.disposed,
        filedDate: DateTime(2024, 11, 28),
      ),
      Case(
        id: 'BA/2024/33333',
        caseType: 'Bail Application',
        petitionerName: 'Vikram Singh vs State of UP',
        status: CaseStatus.pending,
        filedDate: DateTime(2024, 12, 22),
      ),
    ];
  }

  static List<String> getCaseTypes() {
    return [
      'Bail Application',
      'Criminal Revision',
      'Writ Petition',
      'Civil Appeal',
      'Miscellaneous Application',
      'Special Leave Petition',
      'Public Interest Litigation',
      'Habeas Corpus',
    ];
  }
}

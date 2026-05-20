class CaseModel {
  final String id;
  final String caseNumber;
  final String title;
  final String description;
  final String clientId;
  final String lawyerId;
  final String status;
  final String? caseType;
  final String? courtName;
  final String? courtCaseNumber;
  final String? opposingParty;
  final double? caseValue;
  final DateTime? nextHearingDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? clientName;
  final String? lawyerName;

  CaseModel({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.description,
    required this.clientId,
    required this.lawyerId,
    required this.status,
    this.caseType,
    this.courtName,
    this.courtCaseNumber,
    this.opposingParty,
    this.caseValue,
    this.nextHearingDate,
    required this.createdAt,
    required this.updatedAt,
    this.clientName,
    this.lawyerName,
  });

  String get statusLabel {
    switch (status) {
      case 'aktif':
        return 'Aktif';
      case 'beklemede':
        return 'Beklemede';
      case 'kapalı':
        return 'Kapalı';
      default:
        return status;
    }
  }

  factory CaseModel.fromMap(Map<String, dynamic> map) {
    return CaseModel(
      id: map['id'] as String,
      caseNumber: map['case_number'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      clientId: map['client_id'] as String,
      lawyerId: map['lawyer_id'] as String,
      status: map['status'] as String,
      caseType: map['case_type'] as String?,
      courtName: map['court_name'] as String?,
      courtCaseNumber: map['court_case_number'] as String?,
      opposingParty: map['opposing_party'] as String?,
      caseValue: map['case_value'] != null
          ? (map['case_value'] as num).toDouble()
          : null,
      nextHearingDate: map['next_hearing_date'] != null
          ? DateTime.parse(map['next_hearing_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      clientName: map['client_name'] as String?,
      lawyerName: map['lawyer_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'case_number': caseNumber,
      'title': title,
      'description': description,
      'client_id': clientId,
      'lawyer_id': lawyerId,
      'status': status,
      if (caseType != null) 'case_type': caseType,
      if (courtName != null) 'court_name': courtName,
      if (courtCaseNumber != null) 'court_case_number': courtCaseNumber,
      if (opposingParty != null) 'opposing_party': opposingParty,
      if (caseValue != null) 'case_value': caseValue,
      if (nextHearingDate != null)
        'next_hearing_date': nextHearingDate!.toIso8601String().split('T')[0],
    };
  }
}

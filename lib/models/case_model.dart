class CaseModel {
  final String id;
  final String caseNumber;
  final String title;
  final String description;
  final String clientId;
  final String lawyerId;
  final String status; // 'aktif', 'beklemede', 'kapalı'
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
    };
  }
}

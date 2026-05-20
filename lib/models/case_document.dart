class CaseDocument {
  final String id;
  final String caseId;
  final String fileName;
  final String fileUrl;
  final String uploadedBy;
  final DateTime createdAt;

  CaseDocument({
    required this.id,
    required this.caseId,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory CaseDocument.fromMap(Map<String, dynamic> map) {
    return CaseDocument(
      id: map['id'] as String,
      caseId: map['case_id'] as String,
      fileName: map['file_name'] as String,
      fileUrl: map['file_url'] as String,
      uploadedBy: map['uploaded_by'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class LawyerRequest {
  final String id;
  final String muvekkilId;
  final String avukatId;
  final String? message;
  final String status;
  final DateTime createdAt;

  // Join alanları
  final String? muvekkilName;
  final String? muvekkilEmail;
  final String? avukatName;
  final String? avukatBaro;
  final String? avukatUzmanlik;

  const LawyerRequest({
    required this.id,
    required this.muvekkilId,
    required this.avukatId,
    this.message,
    required this.status,
    required this.createdAt,
    this.muvekkilName,
    this.muvekkilEmail,
    this.avukatName,
    this.avukatBaro,
    this.avukatUzmanlik,
  });

  String get statusLabel {
    switch (status) {
      case 'kabul':
        return 'Kabul Edildi';
      case 'red':
        return 'Reddedildi';
      default:
        return 'Beklemede';
    }
  }

  factory LawyerRequest.fromMap(Map<String, dynamic> map) {
    final muvekkil = map['muvekkil'] as Map?;
    final avukat = map['avukat'] as Map?;
    return LawyerRequest(
      id: map['id'] as String,
      muvekkilId: map['muvekkil_id'] as String,
      avukatId: map['avukat_id'] as String,
      message: map['message'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      muvekkilName: muvekkil?['full_name'] as String?,
      muvekkilEmail: muvekkil?['email'] as String?,
      avukatName: avukat?['full_name'] as String?,
      avukatBaro: avukat?['baro_adi'] as String?,
      avukatUzmanlik: avukat?['uzmanlik_alani'] as String?,
    );
  }
}

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final DateTime createdAt;

  // Ortak opsiyonel alanlar
  final String? phone;

  // Avukat alanları
  final String? sicilNo;
  final String? uzmanlikAlani;
  final String? baroAdi;

  // Müvekkil alanları
  final String? tcKimlik;
  final DateTime? birthDate;
  final String? address;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.phone,
    this.sicilNo,
    this.uzmanlikAlani,
    this.baroAdi,
    this.tcKimlik,
    this.birthDate,
    this.address,
  });

  bool get isLawyer => role == 'avukat';

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String,
      role: map['role'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      phone: map['phone'] as String?,
      sicilNo: map['sicil_no'] as String?,
      uzmanlikAlani: map['uzmanlik_alani'] as String?,
      baroAdi: map['baro_adi'] as String?,
      tcKimlik: map['tc_kimlik'] as String?,
      birthDate: map['birth_date'] != null
          ? DateTime.parse(map['birth_date'] as String)
          : null,
      address: map['address'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      if (phone != null) 'phone': phone,
      if (sicilNo != null) 'sicil_no': sicilNo,
      if (uzmanlikAlani != null) 'uzmanlik_alani': uzmanlikAlani,
      if (baroAdi != null) 'baro_adi': baroAdi,
      if (tcKimlik != null) 'tc_kimlik': tcKimlik,
      if (birthDate != null)
        'birth_date': birthDate!.toIso8601String().split('T')[0],
      if (address != null) 'address': address,
    };
  }
}

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'avukat' veya 'müvekkil'
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  bool get isLawyer => role == 'avukat';

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String,
      role: map['role'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

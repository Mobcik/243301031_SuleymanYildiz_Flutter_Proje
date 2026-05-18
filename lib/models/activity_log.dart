class ActivityLog {
  final String id;
  final String userId;
  final String action;
  final String? details;
  final DateTime createdAt;
  final String? userName;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.action,
    this.details,
    required this.createdAt,
    this.userName,
  });

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      action: map['action'] as String,
      details: map['details'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      userName: map['user_name'] as String?,
    );
  }
}

class ExpenseModel {
  final String id;
  final String caseId;
  final double amount;
  final String description;
  final DateTime expenseDate;
  final String createdBy;
  final DateTime createdAt;
  final String? createdByName;

  ExpenseModel({
    required this.id,
    required this.caseId,
    required this.amount,
    required this.description,
    required this.expenseDate,
    required this.createdBy,
    required this.createdAt,
    this.createdByName,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      caseId: map['case_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      expenseDate: DateTime.parse(map['expense_date'] as String),
      createdBy: map['created_by'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      createdByName: map['created_by_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'case_id': caseId,
      'amount': amount,
      'description': description,
      'expense_date': expenseDate.toIso8601String().split('T')[0],
      'created_by': createdBy,
    };
  }
}

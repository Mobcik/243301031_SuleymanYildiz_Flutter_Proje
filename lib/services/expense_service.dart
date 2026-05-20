import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense_model.dart';
import 'log_service.dart';

class ExpenseService {
  final _supabase = Supabase.instance.client;
  final _logService = LogService();

  /// Bir davaya ait masrafları getirir
  Future<List<ExpenseModel>> getCaseExpenses(String caseId) async {
    final response = await _supabase
        .from('expenses')
        .select('*, profiles(full_name)')
        .eq('case_id', caseId)
        .order('expense_date', ascending: false);

    return (response as List).map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      final profile = map['profiles'] as Map?;
      map['created_by_name'] = profile?['full_name'];
      return ExpenseModel.fromMap(map);
    }).toList();
  }

  /// Toplam masraf tutarını hesaplar
  Future<double> getTotalExpenses(String caseId) async {
    final expenses = await getCaseExpenses(caseId);
    double total = 0.0;
    for (final e in expenses) {
      total += e.amount;
    }
    return total;
  }

  /// Yeni masraf ekler
  Future<ExpenseModel> addExpense({
    required String caseId,
    required double amount,
    required String description,
    required DateTime expenseDate,
    required String createdBy,
  }) async {
    final response = await _supabase.from('expenses').insert({
      'case_id': caseId,
      'amount': amount,
      'description': description,
      'expense_date': expenseDate.toIso8601String().split('T')[0],
      'created_by': createdBy,
    }).select().single();

    await _logService.log('Masraf eklendi',
        details: '${amount.toStringAsFixed(2)} TL - $description');
    return ExpenseModel.fromMap(response as Map<String, dynamic>);
  }

  /// Masrafı siler
  Future<void> deleteExpense(String expenseId) async {
    await _supabase.from('expenses').delete().eq('id', expenseId);
    await _logService.log('Masraf silindi');
  }
}

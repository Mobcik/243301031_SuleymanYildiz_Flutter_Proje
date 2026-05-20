import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/expense_card.dart';
import '../../../models/case_model.dart';
import '../../../models/expense_model.dart';
import '../../../services/case_service.dart';
import '../../../services/expense_service.dart';

class MuvekkilCaseDetailScreen extends StatefulWidget {
  final String caseId;
  const MuvekkilCaseDetailScreen({super.key, required this.caseId});

  @override
  State<MuvekkilCaseDetailScreen> createState() =>
      _MuvekkilCaseDetailScreenState();
}

class _MuvekkilCaseDetailScreenState extends State<MuvekkilCaseDetailScreen> {
  final _caseService = CaseService();
  final _expenseService = ExpenseService();

  CaseModel? _case;
  List<ExpenseModel> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final expenses =
          await _expenseService.getCaseExpenses(widget.caseId);
      setState(() => _expenses = expenses);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _total =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  Color get _statusColor {
    switch (_case?.status) {
      case 'aktif':
        return AppColors.statusAktif;
      case 'beklemede':
        return AppColors.statusBeklemede;
      default:
        return AppColors.statusKapali;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dava Detayı'),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Masraf özeti
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Toplam Masraf',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                              Text(
                                '${_total.toStringAsFixed(2)} TL',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.receipt_long,
                                  size: 16,
                                  color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text('${_expenses.length} masraf kaydı',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Masraf listesi
                  if (_expenses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.receipt,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('Henüz masraf kaydı yok',
                                style: TextStyle(
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...(_expenses.map((e) => ExpenseCard(expense: e))),
                ],
              ),
            ),
    );
  }
}

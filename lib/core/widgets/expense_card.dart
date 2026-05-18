import 'package:flutter/material.dart';
import '../../models/expense_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final bool canDelete;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.accent,
          child: Icon(Icons.receipt_long, color: Colors.white, size: 18),
        ),
        title: Text(expense.description),
        subtitle: Text(DateFormatter.formatDate(expense.expenseDate)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${expense.amount.toStringAsFixed(2)} ₺',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
                fontSize: 15,
              ),
            ),
            if (canDelete)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ExpenseFormScreen extends StatelessWidget {
  final String caseId;
  const ExpenseFormScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Expense Form')),
    );
  }
}

import 'package:flutter/material.dart';

class MuvekkilCaseDetailScreen extends StatelessWidget {
  final String caseId;
  const MuvekkilCaseDetailScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Müvekkil Case Detail')),
    );
  }
}

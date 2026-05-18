import 'package:flutter/material.dart';

class AvukatCaseDetailScreen extends StatelessWidget {
  final String caseId;
  const AvukatCaseDetailScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Case Detail')),
    );
  }
}

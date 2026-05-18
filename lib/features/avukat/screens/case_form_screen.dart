import 'package:flutter/material.dart';

class CaseFormScreen extends StatelessWidget {
  final String? caseId;
  const CaseFormScreen({super.key, this.caseId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Case Form')),
    );
  }
}

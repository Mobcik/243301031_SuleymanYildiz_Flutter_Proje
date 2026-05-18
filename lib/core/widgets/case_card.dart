import 'package:flutter/material.dart';
import '../../models/case_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';

class CaseCard extends StatelessWidget {
  final CaseModel caseModel;
  final VoidCallback onTap;

  const CaseCard({super.key, required this.caseModel, required this.onTap});

  Color get _statusColor {
    switch (caseModel.status) {
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.folder, color: Colors.white, size: 20),
        ),
        title: Text(
          caseModel.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dosya No: ${caseModel.caseNumber}'),
            if (caseModel.clientName != null)
              Text('Müvekkil: ${caseModel.clientName}'),
            Text(DateFormatter.formatDate(caseModel.createdAt),
                style: const TextStyle(fontSize: 11)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _statusColor),
          ),
          child: Text(
            caseModel.statusLabel,
            style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/case_model.dart';
import '../../../services/case_service.dart';
import 'expense_form_screen.dart';

class CaseDetailScreen extends StatefulWidget {
  final CaseModel caseModel;
  const CaseDetailScreen({super.key, required this.caseModel});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  final _caseService = CaseService();
  late CaseModel _case;

  @override
  void initState() {
    super.initState();
    _case = widget.caseModel;
  }

  Future<void> _changeStatus(String newStatus) async {
    try {
      await _caseService.updateStatus(_case.id, newStatus);
      setState(() => _case = CaseModel(
            id: _case.id,
            caseNumber: _case.caseNumber,
            title: _case.title,
            description: _case.description,
            clientId: _case.clientId,
            lawyerId: _case.lawyerId,
            status: newStatus,
            createdAt: _case.createdAt,
            updatedAt: DateTime.now(),
            clientName: _case.clientName,
            caseType: _case.caseType,
            courtName: _case.courtName,
            courtCaseNumber: _case.courtCaseNumber,
            opposingParty: _case.opposingParty,
            caseValue: _case.caseValue,
            nextHearingDate: _case.nextHearingDate,
          ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Durum güncellendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  Future<void> _deleteCase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Davayı Sil'),
        content: const Text('Bu davayı silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed != true) return;
    await _caseService.deleteCase(_case.id);
    if (mounted) Navigator.pop(context);
  }

  Color get _statusColor {
    switch (_case.status) {
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
        title: Text('Dosya #${_case.caseNumber}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'sil') {
                _deleteCase();
              } else {
                _changeStatus(v);
              }
            },
            itemBuilder: (_) => [
              if (_case.status != 'aktif')
                const PopupMenuItem(value: 'aktif', child: Text('Aktif Yap')),
              if (_case.status != 'beklemede')
                const PopupMenuItem(
                    value: 'beklemede', child: Text('Beklemeye Al')),
              if (_case.status != 'kapalı')
                const PopupMenuItem(value: 'kapalı', child: Text('Kapat')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'sil',
                child: Text('Davayı Sil',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık kartı
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _case.title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _statusColor),
                          ),
                          child: Text(
                            _case.statusLabel,
                            style: TextStyle(
                                color: _statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _InfoRow(icon: Icons.tag, label: 'Dosya No', value: _case.caseNumber),
                    if (_case.caseType != null)
                      _InfoRow(icon: Icons.category_outlined, label: 'Dava Türü', value: _case.caseType!),
                    if (_case.clientName != null)
                      _InfoRow(icon: Icons.person, label: 'Müvekkil', value: _case.clientName!),
                    if (_case.opposingParty != null)
                      _InfoRow(icon: Icons.person_off_outlined, label: 'Karşı Taraf', value: _case.opposingParty!),
                    if (_case.courtName != null)
                      _InfoRow(icon: Icons.gavel, label: 'Mahkeme', value: _case.courtName!),
                    if (_case.courtCaseNumber != null)
                      _InfoRow(icon: Icons.numbers, label: 'Esas No', value: _case.courtCaseNumber!),
                    _InfoRow(
                        icon: Icons.calendar_today,
                        label: 'Açılış Tarihi',
                        value: DateFormatter.formatDate(_case.createdAt)),
                    if (_case.nextHearingDate != null)
                      _InfoRow(
                          icon: Icons.event,
                          label: 'Sonraki Duruşma',
                          value: DateFormatter.formatDate(_case.nextHearingDate!)),
                    if (_case.caseValue != null)
                      _InfoRow(
                          icon: Icons.attach_money,
                          label: 'Dava Değeri',
                          value: '${_case.caseValue!.toStringAsFixed(2)} TL'),
                    if (_case.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Açıklama',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(_case.description),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Masraf ekle butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExpenseFormScreen(caseId: _case.id),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Masraf Ekle'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

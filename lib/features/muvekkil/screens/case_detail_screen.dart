import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/expense_card.dart';
import '../../../models/case_model.dart';
import '../../../models/expense_model.dart';
import '../../../services/expense_service.dart';

class MuvekkilCaseDetailScreen extends StatefulWidget {
  final CaseModel caseModel;
  const MuvekkilCaseDetailScreen({super.key, required this.caseModel});

  @override
  State<MuvekkilCaseDetailScreen> createState() => _MuvekkilCaseDetailScreenState();
}

class _MuvekkilCaseDetailScreenState extends State<MuvekkilCaseDetailScreen> {
  final _expenseService = ExpenseService();
  List<ExpenseModel> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _loading = true);
    try {
      final expenses = await _expenseService.getCaseExpenses(widget.caseModel.id);
      setState(() => _expenses = expenses);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _total => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  Color get _statusColor {
    switch (widget.caseModel.status) {
      case 'aktif': return AppColors.statusAktif;
      case 'beklemede': return AppColors.statusBeklemede;
      default: return AppColors.statusKapali;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.caseModel;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Gradient başlık
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                c.statusLabel,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dosya No: ${c.caseNumber}',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Dava Bilgileri
                _Section(
                  title: 'Dava Bilgileri',
                  icon: Icons.folder_outlined,
                  children: [
                    if (c.caseType != null)
                      _InfoRow(icon: Icons.category_outlined, label: 'Dava Türü', value: c.caseType!),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Açılış Tarihi',
                      value: DateFormatter.formatDate(c.createdAt),
                    ),
                    if (c.nextHearingDate != null)
                      _InfoRow(
                        icon: Icons.event,
                        label: 'Sonraki Duruşma',
                        value: DateFormatter.formatDate(c.nextHearingDate!),
                        valueColor: AppColors.accent,
                        bold: true,
                      ),
                    if (c.caseValue != null)
                      _InfoRow(
                        icon: Icons.attach_money,
                        label: 'Dava Değeri',
                        value: '${c.caseValue!.toStringAsFixed(2)} TL',
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Taraflar & Mahkeme
                _Section(
                  title: 'Taraflar & Mahkeme',
                  icon: Icons.account_balance_outlined,
                  children: [
                    if (c.opposingParty != null)
                      _InfoRow(icon: Icons.person_off_outlined, label: 'Karşı Taraf', value: c.opposingParty!),
                    if (c.courtName != null)
                      _InfoRow(icon: Icons.gavel, label: 'Mahkeme', value: c.courtName!),
                    if (c.courtCaseNumber != null)
                      _InfoRow(icon: Icons.numbers, label: 'Esas No', value: c.courtCaseNumber!),
                  ],
                ),
                const SizedBox(height: 12),

                // Avukat Bilgisi
                if (c.lawyerName != null) ...[
                  _LawyerCard(
                    name: c.lawyerName!,
                    lawyerId: c.lawyerId,
                  ),
                  const SizedBox(height: 12),
                ],

                // Açıklama
                if (c.description.isNotEmpty) ...[
                  _Section(
                    title: 'Açıklama',
                    icon: Icons.description_outlined,
                    children: [
                      Text(c.description, style: const TextStyle(color: AppColors.textPrimary, height: 1.5)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Masraf Özeti
                _loading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        children: [
                          // Özet kart
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Toplam Masraf',
                                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_total.toStringAsFixed(2)} TL',
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.accent),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('${_expenses.length}',
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary)),
                                        const Text('kayıt',
                                            style: TextStyle(
                                                fontSize: 11, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Masraf listesi
                          if (_expenses.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 8),
                                  Text('Masraf kaydı bulunmuyor',
                                      style: TextStyle(color: Colors.grey.shade500)),
                                ],
                              ),
                            )
                          else
                            ...(_expenses.map((e) => ExpenseCard(expense: e))),
                        ],
                      ),

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Avukat bilgi kartı (profil servisten isim görünür, daha sonra genişletilebilir)
class _LawyerCard extends StatelessWidget {
  final String name;
  final String lawyerId;
  const _LawyerCard({required this.name, required this.lawyerId});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: const Icon(Icons.gavel, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Avukatım',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusAktif.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Aktif',
                  style: TextStyle(
                      color: AppColors.statusAktif,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _Section({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
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
  final Color? valueColor;
  final bool bold;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

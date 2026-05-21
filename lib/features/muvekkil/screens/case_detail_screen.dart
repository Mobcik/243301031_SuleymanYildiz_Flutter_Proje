import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
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
      if (mounted) setState(() => _expenses = expenses);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _total => _expenses.fold(0.0, (s, e) => s + e.amount);

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
    final hearingDays = c.nextHearingDate != null ? DateFormatter.daysUntil(c.nextHearingDate!) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Collapsing Header ──────────────────────────
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A3A6E), AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(c.statusLabel,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          c.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 14,
                          children: [
                            _HeaderChip(icon: Icons.tag, text: 'No: ${c.caseNumber}'),
                            if (c.lawyerName != null)
                              _HeaderChip(icon: Icons.gavel, text: 'Av. ${c.lawyerName!}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Sonraki Duruşma Banner
                if (c.nextHearingDate != null && hearingDays != null) ...[
                  _HearingBanner(date: c.nextHearingDate!, days: hearingDays),
                  const SizedBox(height: 16),
                ],

                // Dava Bilgi Kartları
                _InfoGrid(caseModel: c),
                const SizedBox(height: 16),

                // Taraflar (müvekkil side: avukat + karşı taraf)
                _PartiesCard(
                  leftLabel: 'Avukatım',
                  leftName: c.lawyerName ?? '—',
                  leftIcon: Icons.gavel,
                  leftColor: AppColors.primary,
                  rightLabel: 'Karşı Taraf',
                  rightName: c.opposingParty ?? '—',
                  rightIcon: Icons.person_off_outlined,
                  rightColor: AppColors.error,
                ),
                const SizedBox(height: 16),

                // Mahkeme
                if (c.courtName != null || c.courtCaseNumber != null) ...[
                  _CourtCard(courtName: c.courtName, courtCaseNumber: c.courtCaseNumber),
                  const SizedBox(height: 16),
                ],

                // Açıklama
                if (c.description.isNotEmpty) ...[
                  _DescCard(description: c.description),
                  const SizedBox(height: 16),
                ],

                // Masraflar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Masraflar',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${_expenses.length} kayıt',
                          style: const TextStyle(color: AppColors.primaryLight, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _TotalCard(total: _total),
                const SizedBox(height: 8),

                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_expenses.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text('Masraf kaydı bulunmuyor',
                            style: TextStyle(color: Colors.grey.shade400)),
                      ],
                    ),
                  )
                else
                  ...(_expenses.map((e) => _ReadOnlyExpenseItem(expense: e))),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// WİDGET'LAR
// ═══════════════════════════════════════════════════════

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeaderChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white60),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}

class _HearingBanner extends StatelessWidget {
  final DateTime date;
  final int days;
  const _HearingBanner({required this.date, required this.days});

  String get _daysLabel {
    if (days == 0) return 'Bugün!';
    if (days < 0) return '${days.abs()} gün önce';
    return '$days gün kaldı';
  }

  @override
  Widget build(BuildContext context) {
    final months = ['Ocak','Şubat','Mart','Nisan','Mayıs','Haziran',
        'Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC9A84C), Color(0xFFE8C96A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.accent.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.gavel, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sonraki Duruşma',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  '${date.day} ${months[date.month - 1]} ${date.year}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_daysLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text('${date.day}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, height: 1)),
              Text(months[date.month - 1].substring(0, 3).toUpperCase(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final CaseModel caseModel;
  const _InfoGrid({required this.caseModel});

  @override
  Widget build(BuildContext context) {
    final c = caseModel;
    return Column(
      children: [
        Row(
          children: [
            _InfoCell(
              icon: Icons.category_outlined,
              label: 'Dava Türü',
              value: c.caseType ?? 'Belirtilmedi',
              iconColor: AppColors.primaryLight,
            ),
            const SizedBox(width: 12),
            _InfoCell(
              icon: Icons.monetization_on_outlined,
              label: 'Dava Değeri',
              value: c.caseValue != null ? '${DateFormatter.formatMoney(c.caseValue!)} ₺' : '—',
              iconColor: AppColors.accent,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _InfoCell(
              icon: Icons.calendar_today_outlined,
              label: 'Açılış Tarihi',
              value: DateFormatter.formatDate(c.createdAt),
              iconColor: AppColors.primaryLight,
            ),
            const SizedBox(width: 12),
            _InfoCell(
              icon: Icons.account_balance_outlined,
              label: 'Mahkeme',
              value: c.courtName ?? '—',
              iconColor: AppColors.primaryLight,
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  const _InfoCell({required this.icon, required this.label, required this.value, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 5),
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PartiesCard extends StatelessWidget {
  final String leftLabel;
  final String leftName;
  final IconData leftIcon;
  final Color leftColor;
  final String rightLabel;
  final String rightName;
  final IconData rightIcon;
  final Color rightColor;

  const _PartiesCard({
    required this.leftLabel, required this.leftName,
    required this.leftIcon, required this.leftColor,
    required this.rightLabel, required this.rightName,
    required this.rightIcon, required this.rightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people_outline, size: 16, color: AppColors.primaryLight),
              SizedBox(width: 6),
              Text('Taraflar', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PartyCol(label: leftLabel, name: leftName, icon: leftIcon, color: leftColor),
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 16)),
              Expanded(
                child: _PartyCol(label: rightLabel, name: rightName, icon: rightIcon, color: rightColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartyCol extends StatelessWidget {
  final String label;
  final String name;
  final IconData icon;
  final Color color;
  const _PartyCol({required this.label, required this.name, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 6),
        Text(name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _CourtCard extends StatelessWidget {
  final String? courtName;
  final String? courtCaseNumber;
  const _CourtCard({this.courtName, this.courtCaseNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance, size: 16, color: AppColors.primaryLight),
              SizedBox(width: 6),
              Text('Mahkeme Bilgileri', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          if (courtName != null) ...[
            const SizedBox(height: 12),
            Text(courtName!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
          if (courtCaseNumber != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.numbers, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Esas No: ${courtCaseNumber!}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DescCard extends StatelessWidget {
  final String description;
  const _DescCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined, size: 16, color: AppColors.primaryLight),
              SizedBox(width: 6),
              Text('Açıklama', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6)),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double total;
  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Toplam Masraf', style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text('${DateFormatter.formatMoney(total)} ₺',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ReadOnlyExpenseItem extends StatelessWidget {
  final ExpenseModel expense;
  const _ReadOnlyExpenseItem({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.description,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(DateFormatter.formatDate(expense.expenseDate),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text('${DateFormatter.formatMoney(expense.amount)} ₺',
              style: const TextStyle(
                  color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}

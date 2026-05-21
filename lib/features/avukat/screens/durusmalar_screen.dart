import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/case_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/case_service.dart';
import 'case_detail_screen.dart';

class DurusmalarScreen extends StatefulWidget {
  const DurusmalarScreen({super.key});

  @override
  State<DurusmalarScreen> createState() => _DurusmalarScreenState();
}

class _DurusmalarScreenState extends State<DurusmalarScreen> {
  final _caseService = CaseService();
  List<CaseModel> _hearings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final lawyerId = context.read<AuthProvider>().profile!.id;
      final hearings = await _caseService.getUpcomingHearings(lawyerId);
      if (mounted) setState(() => _hearings = hearings);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Yüklenemedi: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Duruşma Takvimi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _hearings.isEmpty
              ? _EmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: Column(
                    children: [
                      // Üst özet
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.gavel, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${_hearings.length} yaklaşan duruşma',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  _hearings.isNotEmpty
                                      ? 'Sonraki: ${DateFormatter.formatLong(_hearings.first.nextHearingDate!)}'
                                      : '',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Liste
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: _hearings.length,
                          itemBuilder: (context, i) => _HearingCard(
                            caseModel: _hearings[i],
                            isFirst: i == 0,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CaseDetailScreen(caseModel: _hearings[i]),
                                ),
                              );
                              _load();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ─────────────────────────────────────────────
class _HearingCard extends StatelessWidget {
  final CaseModel caseModel;
  final bool isFirst;
  final VoidCallback onTap;

  const _HearingCard({
    required this.caseModel,
    required this.isFirst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = caseModel.nextHearingDate!;
    final days = DateFormatter.daysUntil(date);
    final months = ['Ocak','Şubat','Mart','Nisan','Mayıs','Haziran',
        'Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık'];

    Color urgencyColor;
    String urgencyLabel;
    if (days == 0) {
      urgencyColor = AppColors.error;
      urgencyLabel = 'Bugün';
    } else if (days <= 3) {
      urgencyColor = AppColors.error;
      urgencyLabel = '$days gün kaldı';
    } else if (days <= 7) {
      urgencyColor = AppColors.warning;
      urgencyLabel = '$days gün kaldı';
    } else {
      urgencyColor = AppColors.statusAktif;
      urgencyLabel = '$days gün kaldı';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isFirst
              ? Border.all(color: AppColors.accent, width: 2)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: isFirst
                  ? AppColors.accent.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isFirst ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Tarih kutusu
              Container(
                width: 58,
                height: 68,
                decoration: BoxDecoration(
                  color: isFirst
                      ? AppColors.accent
                      : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isFirst ? Colors.white : AppColors.primary,
                        height: 1,
                      ),
                    ),
                    Text(
                      months[date.month - 1].substring(0, 3).toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isFirst ? Colors.white70 : AppColors.primaryLight,
                      ),
                    ),
                    Text(
                      '${date.year}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isFirst ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Dava bilgisi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFirst)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Sonraki Duruşma',
                            style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    Text(
                      caseModel.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (caseModel.clientName != null)
                      Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(caseModel.clientName!,
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    if (caseModel.courtName != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.account_balance,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(caseModel.courtName!,
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Urgency badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: urgencyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: urgencyColor.withOpacity(0.3)),
                ),
                child: Text(
                  urgencyLabel,
                  style: TextStyle(
                      color: urgencyColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_available, size: 48, color: AppColors.primaryLight),
          ),
          const SizedBox(height: 20),
          const Text('Yaklaşan Duruşma Yok',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Davaları düzenleyerek duruşma tarihi\nekleyebilirsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

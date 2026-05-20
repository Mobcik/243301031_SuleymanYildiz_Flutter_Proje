import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/case_card.dart';
import '../../../layouts/muvekkil_layout.dart';
import '../../../models/case_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/case_service.dart';
import 'case_detail_screen.dart';

class MuvekkilHomeScreen extends StatefulWidget {
  const MuvekkilHomeScreen({super.key});

  @override
  State<MuvekkilHomeScreen> createState() => _MuvekkilHomeScreenState();
}

class _MuvekkilHomeScreenState extends State<MuvekkilHomeScreen> {
  final _caseService = CaseService();
  List<CaseModel> _cases = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    final clientId = context.read<AuthProvider>().profile?.id;
    if (clientId == null) return;

    setState(() => _loading = true);
    try {
      final cases = await _caseService.getClientCases(clientId);
      setState(() => _cases = cases);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Davalar yüklenemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;

    return MuvekkilLayout(
      title: 'Dosyalarım',
      body: Column(
        children: [
          // Üst bilgi kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryLight, AppColors.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoş geldiniz,',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
                Text(
                  profile?.fullName ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoChip(
                        label: 'Toplam Dava', count: _cases.length),
                    const SizedBox(width: 8),
                    _InfoChip(
                      label: 'Aktif',
                      count: _cases.where((c) => c.status == 'aktif').length,
                      color: AppColors.statusAktif,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      label: 'Kapalı',
                      count: _cases.where((c) => c.status == 'kapalı').length,
                      color: AppColors.statusKapali,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _cases.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.folder_open,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Henüz dava kaydınız bulunmuyor.\nAvukatınızla iletişime geçin.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCases,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          itemCount: _cases.length,
                          itemBuilder: (context, i) => CaseCard(
                            caseModel: _cases[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MuvekkilCaseDetailScreen(
                                    caseModel: _cases[i]),
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _InfoChip(
      {required this.label,
      required this.count,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.9), fontSize: 12)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/case_card.dart';
import '../../../layouts/avukat_layout.dart';
import '../../../models/case_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/case_service.dart';
import 'case_detail_screen.dart';
import 'case_form_screen.dart';

class AvukatHomeScreen extends StatefulWidget {
  const AvukatHomeScreen({super.key});

  @override
  State<AvukatHomeScreen> createState() => _AvukatHomeScreenState();
}

class _AvukatHomeScreenState extends State<AvukatHomeScreen> {
  final _caseService = CaseService();
  List<CaseModel> _cases = [];
  List<CaseModel> _filtered = [];
  bool _loading = true;
  String _selectedStatus = 'hepsi';

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    final lawyerId = context.read<AuthProvider>().profile?.id;
    if (lawyerId == null) return;

    setState(() => _loading = true);
    try {
      final cases = await _caseService.getLawyerCases(lawyerId);
      setState(() {
        _cases = cases;
        _applyFilter();
      });
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

  void _applyFilter() {
    if (_selectedStatus == 'hepsi') {
      _filtered = List.from(_cases);
    } else {
      _filtered = _cases.where((c) => c.status == _selectedStatus).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;

    return AvukatLayout(
      title: 'Davalarım',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CaseFormScreen()),
          );
          _loadCases();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Dava'),
      ),
      body: Column(
        children: [
          // Üst özet
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
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
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatChip(
                      label: 'Toplam',
                      count: _cases.length,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Aktif',
                      count: _cases.where((c) => c.status == 'aktif').length,
                      color: AppColors.statusAktif,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Beklemede',
                      count: _cases.where((c) => c.status == 'beklemede').length,
                      color: AppColors.statusBeklemede,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filtre butonları
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Hepsi',
                    selected: _selectedStatus == 'hepsi',
                    onTap: () => setState(() {
                      _selectedStatus = 'hepsi';
                      _applyFilter();
                    }),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Aktif',
                    selected: _selectedStatus == 'aktif',
                    color: AppColors.statusAktif,
                    onTap: () => setState(() {
                      _selectedStatus = 'aktif';
                      _applyFilter();
                    }),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Beklemede',
                    selected: _selectedStatus == 'beklemede',
                    color: AppColors.statusBeklemede,
                    onTap: () => setState(() {
                      _selectedStatus = 'beklemede';
                      _applyFilter();
                    }),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Kapalı',
                    selected: _selectedStatus == 'kapalı',
                    color: AppColors.statusKapali,
                    onTap: () => setState(() {
                      _selectedStatus = 'kapalı';
                      _applyFilter();
                    }),
                  ),
                ],
              ),
            ),
          ),

          // Liste
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.folder_open,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              _cases.isEmpty
                                  ? 'Henüz dava yok\n"Yeni Dava" butonuna basın'
                                  : 'Bu filtrede dava bulunamadı',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCases,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) => CaseCard(
                            caseModel: _filtered[i],
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CaseDetailScreen(
                                      caseModel: _filtered[i]),
                                ),
                              );
                              _loadCases();
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color = AppColors.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade600,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

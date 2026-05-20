import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/lawyer_request.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/request_service.dart';

class TaleplerScreen extends StatefulWidget {
  const TaleplerScreen({super.key});

  @override
  State<TaleplerScreen> createState() => _TaleplerScreenState();
}

class _TaleplerScreenState extends State<TaleplerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _requestService = RequestService();
  List<LawyerRequest> _all = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final avukatId = context.read<AuthProvider>().profile!.id;
      final requests = await _requestService.getAvukatRequests(avukatId);
      if (mounted) setState(() => _all = requests);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Talepler yüklenemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _respond(LawyerRequest req, String status) async {
    final label = status == 'kabul' ? 'kabul edilsin' : 'reddedilsin';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(status == 'kabul' ? 'Talebi Kabul Et' : 'Talebi Reddet'),
        content: Text('${req.muvekkilName ?? "Müvekkil"} talebinin $label mi?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(status == 'kabul' ? 'Kabul Et' : 'Reddet',
                  style: TextStyle(
                      color: status == 'kabul'
                          ? AppColors.statusAktif
                          : AppColors.error))),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _requestService.respondRequest(req.id, status);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(status == 'kabul'
                  ? 'Talep kabul edildi'
                  : 'Talep reddedildi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  List<LawyerRequest> _filtered(String status) =>
      _all.where((r) => r.status == status).toList();

  @override
  Widget build(BuildContext context) {
    final pending = _filtered('beklemede');
    final accepted = _filtered('kabul');
    final rejected = _filtered('red');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Müvekkil Talepleri'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Bekleyen'),
                  if (pending.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${pending.length}',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Kabul'),
            const Tab(text: 'Red'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _RequestList(
                    requests: pending,
                    emptyText: 'Bekleyen talep yok',
                    onRespond: _respond,
                    showActions: true,
                  ),
                  _RequestList(
                    requests: accepted,
                    emptyText: 'Kabul edilen talep yok',
                  ),
                  _RequestList(
                    requests: rejected,
                    emptyText: 'Reddedilen talep yok',
                  ),
                ],
              ),
            ),
    );
  }
}

// ──────────────────────────────────────────────
class _RequestList extends StatelessWidget {
  final List<LawyerRequest> requests;
  final String emptyText;
  final bool showActions;
  final Function(LawyerRequest, String)? onRespond;

  const _RequestList({
    required this.requests,
    required this.emptyText,
    this.showActions = false,
    this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(emptyText,
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: requests.length,
      itemBuilder: (context, i) {
        final req = requests[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.person,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(req.muvekkilName ?? 'Müvekkil',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          if (req.muvekkilEmail != null)
                            Text(req.muvekkilEmail!,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(DateFormatter.formatDate(req.createdAt),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
                if (req.message != null && req.message!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(req.message!,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 13)),
                  ),
                ],
                if (showActions) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => onRespond?.call(req, 'red'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Reddet'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => onRespond?.call(req, 'kabul'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.statusAktif,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Kabul Et'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

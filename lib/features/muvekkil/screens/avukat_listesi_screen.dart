import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/user_profile.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/request_service.dart';

class AvukatListesiScreen extends StatefulWidget {
  const AvukatListesiScreen({super.key});

  @override
  State<AvukatListesiScreen> createState() => _AvukatListesiScreenState();
}

class _AvukatListesiScreenState extends State<AvukatListesiScreen> {
  final _requestService = RequestService();
  List<UserProfile> _avukats = [];
  Map<String, String?> _requestStatuses = {}; // avukatId → status
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final muvekkilId = context.read<AuthProvider>().profile!.id;
      final avukats = await _requestService.getAvukats();
      final statuses = <String, String?>{};
      for (final a in avukats) {
        statuses[a.id] = await _requestService.getRequestStatus(muvekkilId, a.id);
      }
      if (mounted) {
        setState(() {
          _avukats = avukats;
          _requestStatuses = statuses;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Avukatlar yüklenemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendRequest(UserProfile avukat) async {
    final muvekkilId = context.read<AuthProvider>().profile!.id;
    final msgCtrl = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TalepBottomSheet(avukat: avukat, msgCtrl: msgCtrl),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _requestService.sendRequest(
        muvekkilId: muvekkilId,
        avukatId: avukat.id,
        message: msgCtrl.text.trim().isEmpty ? null : msgCtrl.text.trim(),
      );
      setState(() => _requestStatuses[avukat.id] = 'beklemede');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Talep gönderildi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Talep gönderilemedi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Avukat Bul'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _avukats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gavel, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Kayıtlı avukat bulunamadı',
                          style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _avukats.length,
                    itemBuilder: (context, i) {
                      final a = _avukats[i];
                      final status = _requestStatuses[a.id];
                      return _AvukatCard(
                        avukat: a,
                        requestStatus: status,
                        onTalep: () => _sendRequest(a),
                      );
                    },
                  ),
                ),
    );
  }
}

// ──────────────────────────────────────────────
class _AvukatCard extends StatelessWidget {
  final UserProfile avukat;
  final String? requestStatus;
  final VoidCallback onTalep;

  const _AvukatCard({
    required this.avukat,
    required this.requestStatus,
    required this.onTalep,
  });

  Color get _statusColor {
    switch (requestStatus) {
      case 'kabul': return AppColors.statusAktif;
      case 'red': return AppColors.error;
      default: return AppColors.statusBeklemede;
    }
  }

  String get _statusLabel {
    switch (requestStatus) {
      case 'kabul': return 'Kabul Edildi';
      case 'red': return 'Reddedildi';
      default: return 'Beklemede';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: const Icon(Icons.gavel, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(avukat.fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      if (avukat.baroAdi != null)
                        Text(avukat.baroAdi!,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            if (avukat.uzmanlikAlani != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: avukat.uzmanlikAlani!.split(',').map((u) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(u.trim(),
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (requestStatus == null)
                  ElevatedButton.icon(
                    onPressed: onTalep,
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Talep Gönder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _statusColor),
                    ),
                    child: Text(_statusLabel,
                        style: TextStyle(
                            color: _statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
class _TalepBottomSheet extends StatelessWidget {
  final UserProfile avukat;
  final TextEditingController msgCtrl;

  const _TalepBottomSheet({required this.avukat, required this.msgCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Avukata Talep Gönder',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Av. ${avukat.fullName}',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            TextField(
              controller: msgCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Mesajınız (opsiyonel)',
                hintText: 'Dava hakkında kısa bilgi verebilirsiniz...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Talep Gönder',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

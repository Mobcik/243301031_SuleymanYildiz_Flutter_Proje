import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/activity_log.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/log_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _logService = LogService();
  List<ActivityLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final logs = await _logService.getMyLogs();
      setState(() => _logs = logs);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor:
            profile?.isLawyer ?? false ? AppColors.primary : AppColors.primaryLight,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profil başlık
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: profile?.isLawyer ?? false
                      ? [AppColors.gradientStart, AppColors.gradientEnd]
                      : [AppColors.primaryLight, AppColors.gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      profile?.isLawyer ?? false
                          ? Icons.gavel
                          : Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile?.fullName ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      profile?.isLawyer ?? false ? 'Avukat' : 'Müvekkil',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Bilgiler
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bilgilerim',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary)),
                      const Divider(height: 16),
                      _InfoTile(
                          icon: Icons.email_outlined,
                          label: 'E-posta',
                          value: profile?.email ?? '-'),
                      if (profile?.phone != null)
                        _InfoTile(
                            icon: Icons.phone_outlined,
                            label: 'Telefon',
                            value: profile!.phone!),
                      if (profile?.tcKimlik != null)
                        _InfoTile(
                            icon: Icons.credit_card,
                            label: 'TC Kimlik',
                            value: profile!.tcKimlik!),
                      if (profile?.isLawyer == true) ...[
                        if (profile?.sicilNo != null)
                          _InfoTile(
                              icon: Icons.badge_outlined,
                              label: 'Sicil No',
                              value: profile!.sicilNo!),
                        if (profile?.baroAdi != null)
                          _InfoTile(
                              icon: Icons.account_balance_outlined,
                              label: 'Baro',
                              value: profile!.baroAdi!),
                        if (profile?.uzmanlikAlani != null)
                          _InfoTile(
                              icon: Icons.work_outlined,
                              label: 'Uzmanlık',
                              value: profile!.uzmanlikAlani!),
                      ] else ...[
                        if (profile?.address != null)
                          _InfoTile(
                              icon: Icons.location_on_outlined,
                              label: 'Adres',
                              value: profile!.address!),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // İşlem geçmişi
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Son İşlemler',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary)),
                      const Divider(height: 16),
                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else if (_logs.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Henüz işlem yok',
                                style: TextStyle(
                                    color: AppColors.textSecondary)),
                          ),
                        )
                      else
                        ...(_logs.take(10).map((log) => ListTile(
                              dense: true,
                              leading: const Icon(Icons.history,
                                  size: 18, color: AppColors.primaryLight),
                              title: Text(log.action,
                                  style: const TextStyle(fontSize: 13)),
                              subtitle: log.details != null
                                  ? Text(log.details!,
                                      style: const TextStyle(fontSize: 11))
                                  : null,
                              trailing: Text(
                                '${log.createdAt.day}.${log.createdAt.month}.${log.createdAt.year}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                            ))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryLight),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

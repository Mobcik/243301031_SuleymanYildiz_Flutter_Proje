import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

/// Müvekkil rolü için ortak ekran iskeleti (AppBar + Drawer)
class MuvekkilLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  const MuvekkilLayout({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Oturumu kapatmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış Yap',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await AuthService().signOut();
    context.read<AuthProvider>().clear();
    AppRouter.goToLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        actions: [
          ...?actions,
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil',
            onPressed: () => AppRouter.goToProfile(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Kullanıcı bilgisi
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primaryLight),
              accountName: Text(profile?.fullName ?? ''),
              accountEmail: Text(profile?.email ?? ''),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.primaryLight, size: 32),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Dosyalarım'),
              onTap: () {
                Navigator.pop(context);
                AppRouter.goToMuvekkilHome(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outlined),
              title: const Text('Profilim'),
              onTap: () {
                Navigator.pop(context);
                AppRouter.goToProfile(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Çıkış Yap',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}

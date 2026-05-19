import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../../avukat/screens/home_screen.dart';
import '../../muvekkil/screens/home_screen.dart';

/// Uygulama açılışında oturum kontrolü yapan ekran
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  /// Mevcut oturumu kontrol eder ve uygun ekrana yönlendirir
  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final profile = await _authService.getCurrentProfile();

    if (!mounted) return;

    if (profile == null) {
      // Oturum yok, giriş ekranına yönlendir
      _navigate(const LoginScreen());
      return;
    }

    // Oturum var, role göre yönlendir
    context.read<AuthProvider>().setProfile(profile);

    if (profile.isLawyer) {
      _navigate(const AvukatHomeScreen());
    } else {
      _navigate(const MuvekkilHomeScreen());
    }
  }

  void _navigate(Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.gavel, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Hukuk Takip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dosya ve Masraf Takip Sistemi',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

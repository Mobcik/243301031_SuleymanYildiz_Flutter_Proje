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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // İkon çerçevesi
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.6),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.gavel,
                  size: 52,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Hukuk Takip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dosya ve Masraf Takip Sistemi',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 56),
              const CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

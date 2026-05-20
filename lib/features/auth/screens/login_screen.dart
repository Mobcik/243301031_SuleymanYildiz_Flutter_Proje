import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../avukat/screens/home_screen.dart';
import '../../muvekkil/screens/home_screen.dart';
import 'register_screen.dart';

/// Kullanıcı giriş ekranı
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _passwordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Giriş işlemini gerçekleştirir
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      context.read<AuthProvider>().setProfile(profile);

      final screen = profile.isLawyer
          ? const AvukatHomeScreen()
          : const MuvekkilHomeScreen();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => screen),
      );
    } catch (e) {
      String msg = 'E-posta veya şifre hatalı';
      if (e is AuthException) {
        if (e.message.toLowerCase().contains('invalid') ||
            e.message.toLowerCase().contains('credentials') ||
            e.message.toLowerCase().contains('password')) {
          msg = 'E-posta veya şifre hatalı';
        } else {
          msg = 'Giriş yapılamadı. Lütfen tekrar deneyin.';
        }
      }
      setState(() => _errorMessage = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Üst gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 72, bottom: 36),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.7),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.gavel,
                    size: 40,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hukuk Takip',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dosya ve Masraf Takip Sistemi',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Form alanı
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Giriş Yap',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Hesabınıza giriş yapın',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // E-posta
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'E-posta',
                                prefixIcon: const Icon(Icons.email_outlined,
                                    color: AppColors.primaryLight),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryLight, width: 2),
                                ),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? 'E-posta giriniz' : null,
                            ),
                            const SizedBox(height: 16),

                            // Şifre
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible,
                              decoration: InputDecoration(
                                labelText: 'Şifre',
                                prefixIcon: const Icon(Icons.lock_outlined,
                                    color: AppColors.primaryLight),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryLight, width: 2),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => setState(() =>
                                      _passwordVisible = !_passwordVisible),
                                ),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? 'Şifre giriniz' : null,
                            ),

                            // Hata mesajı
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.error.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: AppColors.error, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                          color: AppColors.error, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Giriş butonu
                            ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Giriş Yap',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Kayıt ol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Hesabın yok mu? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        ),
                        child: const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

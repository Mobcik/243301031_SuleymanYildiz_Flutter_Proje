import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_data.dart';
import '../../../core/utils/sicil_validator.dart';
import '../../../core/utils/tc_kimlik_validator.dart';
import '../../avukat/screens/home_screen.dart';
import '../../muvekkil/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Ortak alanlar
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Avukat alanları
  final _sicilController = TextEditingController();
  String? _selectedUzmanlik;
  String? _selectedBaro;

  // Müvekkil alanları
  final _tcController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _birthDate;

  bool _loading = false;
  bool _passwordVisible = false;
  String _selectedRole = AppStrings.roleMuvekkil;
  String? _errorMessage;

  bool get _isLawyer => _selectedRole == AppStrings.roleAvukat;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _sicilController.dispose();
    _tcController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1930),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      helpText: 'Doğum Tarihi Seçin',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLawyer && (_selectedUzmanlik == null || _selectedBaro == null)) {
      setState(() => _errorMessage = 'Lütfen uzmanlık alanı ve baro seçin');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        role: _selectedRole,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        sicilNo: _isLawyer ? _sicilController.text.trim() : null,
        uzmanlikAlani: _isLawyer ? _selectedUzmanlik : null,
        baroAdi: _isLawyer ? _selectedBaro : null,
        tcKimlik: _tcController.text.trim().isEmpty ? null : _tcController.text.trim(),
        birthDate: _birthDate,
        address: !_isLawyer && _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
      );

      if (!mounted) return;
      context.read<AuthProvider>().setProfile(profile);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => profile.isLawyer
              ? const AvukatHomeScreen()
              : const MuvekkilHomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString().contains('already registered')
          ? 'Bu e-posta zaten kayıtlı'
          : 'Kayıt başarısız: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDec(String label, IconData icon, {Color? iconColor}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: iconColor ?? AppColors.primaryLight),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: iconColor ?? AppColors.primaryLight, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56, bottom: 28),
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
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.accent.withOpacity(0.7), width: 2),
                  ),
                  child: const Icon(Icons.person_add,
                      size: 34, color: AppColors.accent),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hesap Oluştur',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Rol seçimi
                    Row(
                      children: [
                        Expanded(
                          child: _RoleCard(
                            label: 'Müvekkil',
                            icon: Icons.person,
                            description: 'Dosyalarımı takip et',
                            selected: !_isLawyer,
                            onTap: () => setState(() {
                              _selectedRole = AppStrings.roleMuvekkil;
                              _sicilController.clear();
                              _selectedUzmanlik = null;
                              _selectedBaro = null;
                              // TC kimlik ve doğum tarihi ortak alan, temizlenmiyor
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RoleCard(
                            label: 'Avukat',
                            icon: Icons.gavel,
                            description: 'Davaları yönet',
                            selected: _isLawyer,
                            onTap: () => setState(() {
                              _selectedRole = AppStrings.roleAvukat;
                              // TC kimlik ve doğum tarihi ortak alan, temizlenmiyor
                              _addressController.clear();
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Kişisel bilgiler kartı
                    Card(
                      elevation: 2,
                      shadowColor: AppColors.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration:
                                  _inputDec('Ad Soyad', Icons.person_outlined),
                              validator: (v) =>
                                  v!.isEmpty ? 'Ad soyad giriniz' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLength: 11,
                              decoration: _inputDec(
                                      'Telefon (05XX...)', Icons.phone_outlined)
                                  .copyWith(counterText: ''),
                              validator: (v) {
                                if (v!.isEmpty) return null;
                                if (v.length != 11 || !v.startsWith('0'))
                                  return 'Geçerli telefon giriniz (05XX...)';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            // TC Kimlik — her iki rol için
                            TextFormField(
                              controller: _tcController,
                              keyboardType: TextInputType.number,
                              maxLength: 11,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration:
                                  _inputDec('TC Kimlik Numarası', Icons.credit_card)
                                      .copyWith(counterText: ''),
                              validator: TcKimlikValidator.validate,
                            ),
                            const SizedBox(height: 12),
                            // Doğum tarihi — her iki rol için
                            GestureDetector(
                              onTap: _pickBirthDate,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration:
                                      _inputDec('Doğum Tarihi', Icons.cake_outlined)
                                          .copyWith(
                                    hintText: 'Seçmek için tıklayın',
                                    suffixIcon: const Icon(
                                        Icons.calendar_today, size: 18),
                                  ),
                                  controller: TextEditingController(
                                    text: _birthDate != null
                                        ? '${_birthDate!.day.toString().padLeft(2, '0')}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.year}'
                                        : '',
                                  ),
                                  validator: (_) => _birthDate == null
                                      ? 'Doğum tarihi seçiniz'
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hesap bilgileri kartı
                    Card(
                      elevation: 2,
                      shadowColor: AppColors.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration:
                                  _inputDec('E-posta', Icons.email_outlined),
                              validator: (v) =>
                                  v!.isEmpty ? 'E-posta giriniz' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible,
                              decoration:
                                  _inputDec('Şifre', Icons.lock_outlined)
                                      .copyWith(
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
                              validator: (v) => v!.length < 6
                                  ? 'En az 6 karakter olmalı'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Avukat özel alanlar
                    if (_isLawyer)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _sicilController,
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration:
                                    _inputDec('Baro Sicil Numarası (5 hane)',
                                            Icons.badge_outlined,
                                            iconColor: AppColors.accent)
                                        .copyWith(counterText: ''),
                                validator: SicilValidator.validate,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _selectedBaro,
                                decoration: _inputDec('Baro',
                                    Icons.account_balance_outlined,
                                    iconColor: AppColors.accent),
                                items: AppData.barolar
                                    .map((b) => DropdownMenuItem(
                                        value: b,
                                        child: Text(b,
                                            style: const TextStyle(
                                                fontSize: 14))))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedBaro = v),
                                validator: (v) =>
                                    v == null ? 'Baro seçiniz' : null,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _selectedUzmanlik,
                                decoration: _inputDec('Uzmanlık Alanı',
                                    Icons.work_outlined,
                                    iconColor: AppColors.accent),
                                items: AppData.uzmanlikAlanlari
                                    .map((u) => DropdownMenuItem(
                                        value: u,
                                        child: Text(u,
                                            style: const TextStyle(
                                                fontSize: 14))))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedUzmanlik = v),
                                validator: (v) =>
                                    v == null ? 'Uzmanlık alanı seçiniz' : null,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Müvekkil özel alan — sadece adres
                    if (!_isLawyer)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextFormField(
                            controller: _addressController,
                            maxLines: 2,
                            decoration: _inputDec(
                                'Adres (opsiyonel)',
                                Icons.location_on_outlined),
                          ),
                        ),
                      ),

                    // Hata mesajı
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_errorMessage!,
                                  style: const TextStyle(
                                      color: AppColors.error, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Kayıt Ol',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5)),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Zaten hesabın var mı? ',
                            style: TextStyle(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Giriş Yap',
                              style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 28,
                color:
                    selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontSize: 13)),
            const SizedBox(height: 2),
            Text(description,
                style: TextStyle(
                    fontSize: 10,
                    color: selected
                        ? AppColors.primary.withOpacity(0.7)
                        : AppColors.textLight),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

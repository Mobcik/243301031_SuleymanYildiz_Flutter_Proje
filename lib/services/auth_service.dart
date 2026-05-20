import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'log_service.dart';

/// Kimlik doğrulama işlemlerini yöneten servis
class AuthService {
  final _supabase = Supabase.instance.client;
  final _logService = LogService();

  /// Giriş yapmış kullanıcıyı döndürür
  User? get currentUser => _supabase.auth.currentUser;

  /// Kullanıcının oturum açık mı kontrol eder
  bool get isLoggedIn => currentUser != null;

  /// Oturum değişikliklerini dinleyen stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Mevcut kullanıcının profil bilgilerini getirir
  Future<UserProfile?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      return UserProfile.fromMap(response);
    } catch (_) {
      return null;
    }
  }

  /// E-posta ve şifre ile giriş yapar
  Future<UserProfile> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) throw Exception('Giriş başarısız');

    final profile = await getCurrentProfile();
    if (profile == null) throw Exception('Kullanıcı profili bulunamadı');

    await _logService.log('Giriş yapıldı', details: 'E-posta: $email');
    return profile;
  }

  /// Yeni kullanıcı kaydı oluşturur
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    // Avukat alanları
    String? sicilNo,
    String? uzmanlikAlani,
    String? baroAdi,
    // Müvekkil alanları
    String? tcKimlik,
    DateTime? birthDate,
    String? address,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) throw Exception('Kayıt başarısız');

    final userId = response.user!.id;

    // Auth kaydından sonra profiles tablosuna kullanıcı bilgileri eklenir
    await _supabase.from('profiles').insert({
      'id': userId,
      'email': email,
      'full_name': fullName,
      'role': role,
      if (phone != null) 'phone': phone,
      if (sicilNo != null) 'sicil_no': sicilNo,
      if (uzmanlikAlani != null) 'uzmanlik_alani': uzmanlikAlani,
      if (baroAdi != null) 'baro_adi': baroAdi,
      if (tcKimlik != null) 'tc_kimlik': tcKimlik,
      if (birthDate != null) 'birth_date': birthDate.toIso8601String().split('T')[0],
      if (address != null) 'address': address,
    });

    await _logService.log('Hesap oluşturuldu', details: 'Rol: $role');

    return UserProfile(
      id: userId,
      email: email,
      fullName: fullName,
      role: role,
      createdAt: DateTime.now(),
      phone: phone,
      sicilNo: sicilNo,
      uzmanlikAlani: uzmanlikAlani,
      baroAdi: baroAdi,
      tcKimlik: tcKimlik,
      birthDate: birthDate,
      address: address,
    );
  }

  /// Oturumu kapatır
  Future<void> signOut() async {
    await _logService.log('Çıkış yapıldı');
    await _supabase.auth.signOut();
  }

  /// Sistemdeki tüm müvekkilleri listeler (avukat için)
  Future<List<UserProfile>> getClients() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('role', 'müvekkil')
        .order('full_name');

    return (response as List)
        .map((e) => UserProfile.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}

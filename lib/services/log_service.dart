import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity_log.dart';

/// Kullanıcı işlemlerini veritabanına kaydeden servis
class LogService {
  final _supabase = Supabase.instance.client;

  /// Yeni bir log kaydı oluşturur
  Future<void> log(String action, {String? details}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('activity_logs').insert({
        'user_id': userId,
        'action': action,
        'details': details,
      });
    } catch (_) {
      // Log hatası uygulamayı durdurmamalı
    }
  }

  /// Sadece mevcut kullanıcının kendi loglarını getirir (giriş/çıkış hariç)
  Future<List<ActivityLog>> getMyLogs() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('activity_logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);

    // Giriş/çıkış/kayıt işlemlerini istemci tarafında filtrele
    const excluded = {'Giriş yapıldı', 'Çıkış yapıldı', 'Hesap oluşturuldu'};
    return (response as List)
        .map((item) => ActivityLog.fromMap(Map<String, dynamic>.from(item as Map)))
        .where((log) => !excluded.contains(log.action))
        .take(20)
        .toList();
  }

  /// Tüm logları kullanıcı adıyla birlikte getirir (admin amaçlı)
  Future<List<ActivityLog>> getLogs() async {
    final response = await _supabase
        .from('activity_logs')
        .select('*, profiles(full_name)')
        .order('created_at', ascending: false)
        .limit(100);

    return (response as List).map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final profile = map['profiles'] as Map?;
      map['user_name'] = profile?['full_name'] as String?;
      return ActivityLog.fromMap(map);
    }).toList();
  }
}

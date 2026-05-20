import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lawyer_request.dart';
import '../models/user_profile.dart';

class RequestService {
  final _supabase = Supabase.instance.client;
  static const _table = 'lawyer_client_requests';

  /// Tüm kayıtlı avukatları getirir
  Future<List<UserProfile>> getAvukats() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('role', 'avukat')
        .order('full_name');
    return (response as List)
        .map((e) => UserProfile.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Müvekkil, avukata talep gönderir
  Future<void> sendRequest({
    required String muvekkilId,
    required String avukatId,
    String? message,
  }) async {
    await _supabase.from(_table).upsert({
      'muvekkil_id': muvekkilId,
      'avukat_id': avukatId,
      'message': message,
      'status': 'beklemede',
    }, onConflict: 'muvekkil_id,avukat_id');
  }

  /// Müvekkilin gönderdiği talepleri getirir
  Future<List<LawyerRequest>> getMuvekkilRequests(String muvekkilId) async {
    final response = await _supabase
        .from(_table)
        .select('*, avukat:profiles!lawyer_client_requests_avukat_id_fkey(full_name, baro_adi, uzmanlik_alani)')
        .eq('muvekkil_id', muvekkilId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => LawyerRequest.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Avukata gelen bekleyen talepleri getirir
  Future<List<LawyerRequest>> getAvukatRequests(String avukatId) async {
    final response = await _supabase
        .from(_table)
        .select('*, muvekkil:profiles!lawyer_client_requests_muvekkil_id_fkey(full_name, email, phone)')
        .eq('avukat_id', avukatId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => LawyerRequest.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Belirli avukata talep durumunu öğrenir (null = talep yok)
  Future<String?> getRequestStatus(String muvekkilId, String avukatId) async {
    final response = await _supabase
        .from(_table)
        .select('status')
        .eq('muvekkil_id', muvekkilId)
        .eq('avukat_id', avukatId)
        .maybeSingle();
    return response?['status'] as String?;
  }

  /// Avukat talebi kabul veya reddeder
  Future<void> respondRequest(String requestId, String status) async {
    await _supabase
        .from(_table)
        .update({'status': status})
        .eq('id', requestId);
  }

  /// Beklemedeki talep sayısı (avukat için badge)
  Future<int> getPendingCount(String avukatId) async {
    final response = await _supabase
        .from(_table)
        .select('id')
        .eq('avukat_id', avukatId)
        .eq('status', 'beklemede');
    return (response as List).length;
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/case_model.dart';
import 'log_service.dart';

class CaseService {
  final _supabase = Supabase.instance.client;
  final _logService = LogService();

  /// Avukatın tüm davalarını getirir
  Future<List<CaseModel>> getLawyerCases(String lawyerId) async {
    final response = await _supabase
        .from('cases')
        .select('*, profiles!cases_client_id_fkey(full_name)')
        .eq('lawyer_id', lawyerId)
        .order('created_at', ascending: false);

    return (response as List).map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      final client = map['profiles'] as Map?;
      map['client_name'] = client?['full_name'];
      return CaseModel.fromMap(map);
    }).toList();
  }

  /// Müvekkilin davalarını getirir
  Future<List<CaseModel>> getClientCases(String clientId) async {
    final response = await _supabase
        .from('cases')
        .select('*, profiles!cases_lawyer_id_fkey(full_name)')
        .eq('client_id', clientId)
        .order('created_at', ascending: false);

    return (response as List).map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      final lawyer = map['profiles'] as Map?;
      map['lawyer_name'] = lawyer?['full_name'];
      return CaseModel.fromMap(map);
    }).toList();
  }

  /// Yeni dava oluşturur
  Future<CaseModel> createCase({
    required String caseNumber,
    required String title,
    required String description,
    required String clientId,
    required String lawyerId,
  }) async {
    final response = await _supabase.from('cases').insert({
      'case_number': caseNumber,
      'title': title,
      'description': description,
      'client_id': clientId,
      'lawyer_id': lawyerId,
      'status': 'aktif',
    }).select().single();

    await _logService.log('Dava oluşturuldu', details: 'Dosya No: $caseNumber');
    return CaseModel.fromMap(response as Map<String, dynamic>);
  }

  /// Dava durumunu günceller
  Future<void> updateStatus(String caseId, String status) async {
    await _supabase
        .from('cases')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', caseId);
    await _logService.log('Dava durumu güncellendi', details: 'Yeni durum: $status');
  }

  /// Davayı siler
  Future<void> deleteCase(String caseId) async {
    await _supabase.from('cases').delete().eq('id', caseId);
    await _logService.log('Dava silindi');
  }
}

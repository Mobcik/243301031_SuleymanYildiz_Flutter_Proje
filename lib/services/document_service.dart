import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/case_document.dart';
import 'log_service.dart';

class DocumentService {
  final _supabase = Supabase.instance.client;
  final _logService = LogService();
  static const _bucket = 'documents';

  /// Belgeyi Storage'a yükler ve veritabanına kaydeder
  Future<CaseDocument> uploadDocument({
    required String caseId,
    required String uploadedBy,
    required File file,
    required String fileName,
  }) async {
    final ext = fileName.split('.').last;
    final storagePath = '$caseId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _supabase.storage.from(_bucket).upload(storagePath, file);
    final fileUrl =
        _supabase.storage.from(_bucket).getPublicUrl(storagePath);

    final response = await _supabase.from('case_documents').insert({
      'case_id': caseId,
      'file_name': fileName,
      'file_url': fileUrl,
      'uploaded_by': uploadedBy,
    }).select().single();

    await _logService.log('Belge yüklendi', details: fileName);
    return CaseDocument.fromMap(response as Map<String, dynamic>);
  }

  /// Davaya ait belgeleri listeler
  Future<List<CaseDocument>> getCaseDocuments(String caseId) async {
    final response = await _supabase
        .from('case_documents')
        .select()
        .eq('case_id', caseId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => CaseDocument.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Belgeyi siler
  Future<void> deleteDocument(String documentId, String fileUrl) async {
    final path = Uri.parse(fileUrl).pathSegments.skipWhile((s) => s != _bucket).skip(1).join('/');
    await _supabase.storage.from(_bucket).remove([path]);
    await _supabase.from('case_documents').delete().eq('id', documentId);
    await _logService.log('Belge silindi');
  }
}

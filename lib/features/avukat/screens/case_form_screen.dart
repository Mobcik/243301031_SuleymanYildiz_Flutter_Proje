import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/case_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/case_service.dart';

class CaseFormScreen extends StatefulWidget {
  /// null → yeni dava, dolu → düzenleme modu
  final CaseModel? existingCase;

  const CaseFormScreen({super.key, this.existingCase});

  bool get isEditing => existingCase != null;

  @override
  State<CaseFormScreen> createState() => _CaseFormScreenState();
}

class _CaseFormScreenState extends State<CaseFormScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  final _caseService = CaseService();
  final _authService = AuthService();

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // Adım 1
  final _caseNumberCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  String _caseType = 'Hukuk';
  DateTime _openingDate = DateTime.now();

  // Adım 2
  List<Map<String, String>> _clients = [];
  String? _selectedClientId;
  final _opposingPartyCtrl = TextEditingController();
  final _courtNameCtrl = TextEditingController();
  final _courtCaseNumberCtrl = TextEditingController();

  // Adım 3
  DateTime? _nextHearingDate;
  final _caseValueCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // Adım 4
  final _belgeNotCtrl = TextEditingController();

  bool _loading = false;
  bool _clientsLoading = true;

  static const List<String> _caseTypes = [
    'Hukuk', 'Ceza', 'Idari', 'Icra', 'Arabuluculuk', 'Ticaret', 'Is', 'Aile',
  ];

  @override
  void initState() {
    super.initState();
    _loadClients();
    _prefillIfEditing();
  }

  void _prefillIfEditing() {
    final c = widget.existingCase;
    if (c == null) return;
    _caseNumberCtrl.text = c.caseNumber;
    _titleCtrl.text = c.title;
    _caseType = c.caseType ?? 'Hukuk';
    _openingDate = c.createdAt;
    _selectedClientId = c.clientId;
    _opposingPartyCtrl.text = c.opposingParty ?? '';
    _courtNameCtrl.text = c.courtName ?? '';
    _courtCaseNumberCtrl.text = c.courtCaseNumber ?? '';
    _nextHearingDate = c.nextHearingDate;
    _caseValueCtrl.text = c.caseValue != null ? c.caseValue!.toStringAsFixed(2) : '';
    _descriptionCtrl.text = c.description;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _caseNumberCtrl.dispose();
    _titleCtrl.dispose();
    _opposingPartyCtrl.dispose();
    _courtNameCtrl.dispose();
    _courtCaseNumberCtrl.dispose();
    _caseValueCtrl.dispose();
    _descriptionCtrl.dispose();
    _belgeNotCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    try {
      final profiles = await _authService.getClients();
      if (mounted) {
        setState(() {
          _clients = profiles.map((p) => {'id': p.id, 'name': p.fullName}).toList();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _clientsLoading = false);
    }
  }

  Future<void> _pickDate({required bool isOpening}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isOpening ? _openingDate : (_nextHearingDate ?? now),
      firstDate: isOpening ? DateTime(2000) : DateTime(2000),
      lastDate: DateTime(2040),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isOpening) {
        _openingDate = picked;
      } else {
        _nextHearingDate = picked;
      }
    });
  }

  void _nextStep() {
    bool valid = true;
    if (_currentStep == 0) valid = _step1Key.currentState!.validate();
    if (_currentStep == 1) {
      valid = _step2Key.currentState!.validate();
      if (_selectedClientId == null && !widget.isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen müvekkil seçiniz')),
        );
        return;
      }
    }
    if (_currentStep == 2) valid = _step3Key.currentState!.validate();
    if (!valid) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final double? caseValue = _caseValueCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_caseValueCtrl.text.trim().replaceAll(',', '.'));

      if (widget.isEditing) {
        // ── Güncelleme modu ─────────────────────────
        final updated = await _caseService.updateCase(
          caseId: widget.existingCase!.id,
          title: _titleCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          caseType: _caseType,
          courtName: _courtNameCtrl.text.trim().isEmpty ? null : _courtNameCtrl.text.trim(),
          courtCaseNumber: _courtCaseNumberCtrl.text.trim().isEmpty ? null : _courtCaseNumberCtrl.text.trim(),
          opposingParty: _opposingPartyCtrl.text.trim().isEmpty ? null : _opposingPartyCtrl.text.trim(),
          caseValue: caseValue,
          nextHearingDate: _nextHearingDate,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dava güncellendi')),
          );
          Navigator.pop(context, updated); // güncellenen modeli geri döndür
        }
      } else {
        // ── Yeni dava ─────────────────────────────
        final lawyerId = context.read<AuthProvider>().profile!.id;
        await _caseService.createCase(
          caseNumber: _caseNumberCtrl.text.trim(),
          title: _titleCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          clientId: _selectedClientId!,
          lawyerId: lawyerId,
          caseType: _caseType,
          courtName: _courtNameCtrl.text.trim().isEmpty ? null : _courtNameCtrl.text.trim(),
          courtCaseNumber: _courtCaseNumberCtrl.text.trim().isEmpty ? null : _courtCaseNumberCtrl.text.trim(),
          opposingParty: _opposingPartyCtrl.text.trim().isEmpty ? null : _opposingPartyCtrl.text.trim(),
          caseValue: caseValue,
          nextHearingDate: _nextHearingDate,
          openingDate: _openingDate,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dava başarıyla oluşturuldu')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String label, IconData icon, {Color? color}) {
    final c = color ?? AppColors.primaryLight;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: c),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: 2),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Davayı Düzenle' : 'Yeni Dava Oluştur'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _StepIndicator(current: _currentStep, total: _totalSteps),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(), _buildStep2(), _buildStep3(), _buildStep4()],
            ),
          ),
          // Alt butonlar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prevStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Geri'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _currentStep == _totalSteps - 1
                                ? (widget.isEditing ? 'Kaydet' : 'Davayı Oluştur')
                                : 'İleri',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Adım 1: Temel Bilgiler ───────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepTitle(title: 'Temel Bilgiler', icon: Icons.folder_outlined),
            const SizedBox(height: 16),
            TextFormField(
              controller: _caseNumberCtrl,
              decoration: _dec('Dosya Numarası *', Icons.tag),
              validator: (v) => v!.isEmpty ? 'Dosya numarası giriniz' : null,
              // Düzenleme modunda dosya numarası değiştirilemesin
              readOnly: widget.isEditing,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleCtrl,
              decoration: _dec('Dava Başlığı *', Icons.title),
              validator: (v) => v!.isEmpty ? 'Dava başlığı giriniz' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _caseType,
              decoration: _dec('Dava Türü *', Icons.category_outlined),
              items: _caseTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _caseType = v!),
            ),
            const SizedBox(height: 12),
            // Düzenleme modunda açılış tarihi değiştirilemez
            GestureDetector(
              onTap: widget.isEditing ? null : () => _pickDate(isOpening: true),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: _dec(
                    widget.isEditing ? 'Açılış Tarihi (değiştirilemez)' : 'Açılış Tarihi *',
                    Icons.calendar_today,
                    color: widget.isEditing ? Colors.grey : AppColors.primaryLight,
                  ).copyWith(suffixIcon: widget.isEditing ? null : const Icon(Icons.edit_calendar)),
                  controller: TextEditingController(text: _formatDate(_openingDate)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Adım 2: Taraf & Mahkeme ─────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepTitle(title: 'Taraf & Mahkeme', icon: Icons.account_balance_outlined),
            const SizedBox(height: 16),
            // Düzenleme modunda müvekkil değiştirilemez — sadece göster
            if (widget.isEditing)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outlined, color: Colors.grey),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Müvekkil',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(
                          _clients.firstWhere(
                            (c) => c['id'] == _selectedClientId,
                            orElse: () => {'name': widget.existingCase?.clientName ?? '—'},
                          )['name']!,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              _clientsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedClientId,
                      decoration: _dec('Müvekkil *', Icons.person_outlined),
                      items: _clients
                          .map((c) => DropdownMenuItem(
                              value: c['id'],
                              child: Text(c['name']!,
                                  style: const TextStyle(fontSize: 14))))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedClientId = v),
                      hint: _clients.isEmpty
                          ? const Text('Kayıtlı müvekkil yok')
                          : const Text('Müvekkil seçin'),
                      validator: (v) => v == null ? 'Müvekkil seçiniz' : null,
                    ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _opposingPartyCtrl,
              decoration: _dec('Karşı Taraf Adı *', Icons.person_off_outlined),
              validator: (v) => v!.isEmpty ? 'Karşı taraf adı giriniz' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _courtNameCtrl,
              decoration: _dec('Mahkeme Adı', Icons.gavel),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _courtCaseNumberCtrl,
              decoration: _dec('Esas Numarası (2024/1234)', Icons.numbers),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d/]'))],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Adım 3: Dava Detayları ──────────────────────
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _step3Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepTitle(title: 'Dava Detayları', icon: Icons.info_outline),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _pickDate(isOpening: false),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration:
                      _dec('Sonraki Duruşma Tarihi', Icons.event_outlined, color: AppColors.accent)
                          .copyWith(
                              hintText: 'Seçmek için tıklayın',
                              suffixIcon: _nextHearingDate != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () => setState(() => _nextHearingDate = null),
                                    )
                                  : const Icon(Icons.edit_calendar)),
                  controller: TextEditingController(
                    text: _nextHearingDate != null ? _formatDate(_nextHearingDate!) : '',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _caseValueCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
              decoration: _dec('Dava Değeri (TL)', Icons.attach_money),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 4,
              decoration: _dec('Açıklama / Notlar', Icons.description_outlined),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Adım 4: Ek Notlar ───────────────────────────
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle(title: 'Ek Notlar (Opsiyonel)', icon: Icons.note_outlined),
          const SizedBox(height: 8),
          Text(
            'Davayla ilgili eklemek istediğiniz notları girebilirsiniz.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _belgeNotCtrl,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Örnek: Deliller, tanık listesi, önemli tarihler...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primaryLight, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isEditing
                        ? 'Değişiklikler kaydedildikten sonra dava detay ekranına döneceksiniz.'
                        : 'Davayı kaydettikten sonra masraf ekleyebilir ve durum güncelleyebilirsiniz.',
                    style: TextStyle(color: AppColors.primaryLight, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final labels = ['Temel', 'Taraflar', 'Detaylar', 'Notlar'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: List.generate(total, (i) {
          final done = i < current;
          final active = i == current;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? AppColors.statusAktif
                              : active
                                  ? AppColors.primary
                                  : Colors.grey.shade200,
                        ),
                        child: Center(
                          child: done
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
                              : Text('${i + 1}',
                                  style: TextStyle(
                                      color: active ? Colors.white : Colors.grey.shade500,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(labels[i],
                          style: TextStyle(
                              fontSize: 10,
                              color: active ? AppColors.primary : Colors.grey.shade500,
                              fontWeight:
                                  active ? FontWeight.w600 : FontWeight.normal)),
                    ],
                  ),
                ),
                if (i < total - 1)
                  Expanded(
                      child: Container(
                          height: 2,
                          color: done ? AppColors.statusAktif : Colors.grey.shade300)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _StepTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

/// Baro Sicil Numarası doğrulama kuralları:
/// - Tam 5 haneli olmalı
/// - İlk hane 0 olamaz (10000–99999 arası)
/// - Rakamlar toplamı 3'e bölünebilmeli (checksum)
class SicilValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Baro sicil numarası giriniz';
    }

    // Sadece rakam içermeli
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Sicil numarası yalnızca rakamlardan oluşmalı';
    }

    // Tam 5 hane olmalı
    if (value.length != 5) {
      return 'Sicil numarası 5 haneli olmalı';
    }

    // İlk hane 0 olamaz
    if (value[0] == '0') {
      return 'Sicil numarası 0 ile başlayamaz';
    }

    // Rakamlar toplamı 3'e bölünebilmeli (checksum)
    final sum = value.split('').fold(0, (s, c) => s + int.parse(c));
    if (sum % 3 != 0) {
      return 'Geçersiz sicil numarası';
    }

    return null;
  }

  /// Geçerli bir sicil numarası olup olmadığını boolean döndürür
  static bool isValid(String value) => validate(value) == null;
}

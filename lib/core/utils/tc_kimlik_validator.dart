/// TC Kimlik Numarası doğrulama kuralları (resmi algoritma):
/// - 11 haneli olmalı
/// - İlk hane 0 olamaz
/// - 1,3,5,7,9. haneler toplamı × 7 - 2,4,6,8. haneler toplamı → mod 10 = 10. hane
/// - İlk 10 hanenin toplamı → mod 10 = 11. hane
class TcKimlikValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'TC Kimlik numarası giriniz';
    }

    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
      return 'TC Kimlik 11 haneli olmalı';
    }

    if (value[0] == '0') {
      return 'TC Kimlik 0 ile başlayamaz';
    }

    final d = value.split('').map(int.parse).toList();

    // 10. hane kontrolü
    final tenth = ((d[0] + d[2] + d[4] + d[6] + d[8]) * 7 -
            (d[1] + d[3] + d[5] + d[7])) %
        10;
    if (tenth != d[9]) return 'Geçersiz TC Kimlik numarası';

    // 11. hane kontrolü
    final eleventh =
        (d[0] + d[1] + d[2] + d[3] + d[4] + d[5] + d[6] + d[7] + d[8] + d[9]) %
            10;
    if (eleventh != d[10]) return 'Geçersiz TC Kimlik numarası';

    return null;
  }

  static bool isValid(String value) => validate(value) == null;
}

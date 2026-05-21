import 'package:intl/intl.dart';

class DateFormatter {
  static final _dateFormat = DateFormat('dd.MM.yyyy');
  static final _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

  static const _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  static String formatLong(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  static String monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

  static int daysUntil(DateTime d) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return d.difference(today).inDays;
  }

  static String formatMoney(double v) {
    return NumberFormat('#,##0.00', 'tr_TR').format(v);
  }
}

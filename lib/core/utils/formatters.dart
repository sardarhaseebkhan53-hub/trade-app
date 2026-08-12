import 'package:intl/intl.dart';

class AurumFormatters {
  static final _price = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _compact = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 1);
  static final _percent = NumberFormat('+#0.00%;-0.00%');

  static String price(double value) => _price.format(value);
  static String compactCurrency(double value) => _compact.format(value);
  static String percent(double value) => _percent.format(value / 100);

  static String compactDate(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inMinutes < 2) return 'just now';
    if (now.difference(dt).inHours < 24) return DateFormat.Hm().format(dt);
    return DateFormat.MMMd().format(dt);
  }
}

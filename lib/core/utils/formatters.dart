import 'package:intl/intl.dart';

abstract final class AurumFormatters {
  static String price(double value) {
    final digits = value >= 1000 ? 2 : value >= 1 ? 2 : 4;
    return NumberFormat.currency(symbol: '\$', decimalDigits: digits).format(value);
  }

  static String compactCurrency(double value) =>
      NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 2).format(value);

  static String change(double value) => '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%';

  static String compactDate(DateTime value) => DateFormat('MMM d · HH:mm').format(value.toLocal());
}

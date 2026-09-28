/// PHP currency formatting utility.
import 'package:intl/intl.dart';

class CurrencyFormat {
  CurrencyFormat._();

  static final _formatter = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  static final _compactFormatter = NumberFormat.compactCurrency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 1,
  );

  /// Format amount as ₱1,234.56
  static String format(double amount) => _formatter.format(amount);

  /// Format amount as ₱1.2K for compact display
  static String compact(double amount) => _compactFormatter.format(amount);

  /// Format with sign: +₱1,234.56 or -₱1,234.56
  static String formatSigned(double amount) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${_formatter.format(amount)}';
  }
}

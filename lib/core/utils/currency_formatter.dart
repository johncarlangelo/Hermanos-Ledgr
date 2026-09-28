import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat('#,##0.00', 'en_PH');
  static final NumberFormat _compactFormatter = NumberFormat.compact(locale: 'en_PH');

  /// Formats amount to standard Philippine Peso format: ₱12,345.67
  /// If [showSign] is true, adds '+' for positive values.
  static String format(
    double amount, {
    bool showSign = false,
    bool includeDecimals = true,
  }) {
    final absAmount = amount.abs();
    final formattedNumber = includeDecimals
        ? _formatter.format(absAmount)
        : NumberFormat('#,##0', 'en_PH').format(absAmount);

    if (amount < 0) {
      return '-₱$formattedNumber';
    } else if (amount > 0 && showSign) {
      return '+₱$formattedNumber';
    } else {
      return '₱$formattedNumber';
    }
  }

  /// Compact representation for hero widgets or widgets with limited width.
  /// E.g. ₱125.4K or ₱1.2M
  static String formatCompact(double amount) {
    if (amount.abs() < 100000) {
      return format(amount);
    }
    final prefix = amount < 0 ? '-₱' : '₱';
    return '$prefix${_compactFormatter.format(amount.abs())}';
  }
}

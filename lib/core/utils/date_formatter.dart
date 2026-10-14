import 'package:intl/intl.dart';

/// Centralized date formatting utilities adhering to Hermanos Ledgr Calm Finance design.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _compactFormat = DateFormat('MMM d');
  static final DateFormat _fullDateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dayOfWeekFormat = DateFormat('EEEE, MMM d');

  /// Formats date into relative header ('Today', 'Yesterday', or 'Wednesday, Oct 14').
  static String relativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return 'Today';
    } else if (target == yesterday) {
      return 'Yesterday';
    } else {
      return _dayOfWeekFormat.format(date);
    }
  }

  /// Formats date into full Month and Year (e.g., 'October 2026').
  static String monthYear(DateTime date) => _monthYearFormat.format(date);

  /// Formats date into compact representation (e.g., 'Oct 14').
  static String compact(DateTime date) => _compactFormat.format(date);

  /// Formats date into full standard display (e.g., 'Oct 14, 2026').
  static String full(DateTime date) => _fullDateFormat.format(date);

  /// Formats time of day (e.g., '2:30 PM').
  static String time(DateTime date) => _timeFormat.format(date);

  /// Checks if two timestamps fall on the exact same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

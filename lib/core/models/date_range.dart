import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Preset enum for quick date filtering.
enum DateRangePreset {
  allTime,
  today,
  yesterday,
  thisWeek,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}

/// Immutable value object representing a date interval [start, end].
@immutable
class DateRange {
  final DateTime start;
  final DateTime end;
  final DateRangePreset preset;

  const DateRange({
    required this.start,
    required this.end,
    this.preset = DateRangePreset.custom,
  });

  /// Factory for Today [start of day, end of day].
  factory DateRange.today() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    return DateRange(start: start, end: end, preset: DateRangePreset.today);
  }

  /// Factory for Yesterday.
  factory DateRange.yesterday() {
    final now = DateTime.now().subtract(const Duration(days: 1));
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    return DateRange(start: start, end: end, preset: DateRangePreset.yesterday);
  }

  /// Factory for Current Month.
  factory DateRange.thisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final end = DateTime(now.year, now.month, lastDay, 23, 59, 59, 999);
    return DateRange(start: start, end: end, preset: DateRangePreset.thisMonth);
  }

  /// Factory for Last Month.
  factory DateRange.lastMonth() {
    final now = DateTime.now();
    final year = now.month == 1 ? now.year - 1 : now.year;
    final month = now.month == 1 ? 12 : now.month - 1;
    final start = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0).day;
    final end = DateTime(year, month, lastDay, 23, 59, 59, 999);
    return DateRange(start: start, end: end, preset: DateRangePreset.lastMonth);
  }

  /// Factory for Current Year.
  factory DateRange.thisYear() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
    return DateRange(start: start, end: end, preset: DateRangePreset.thisYear);
  }

  /// Factory covering all time (arbitrary wide boundaries).
  factory DateRange.allTime() {
    return DateRange(
      start: DateTime(2000, 1, 1),
      end: DateTime(2100, 12, 31, 23, 59, 59, 999),
      preset: DateRangePreset.allTime,
    );
  }

  /// Checks if a given timestamp falls within this range (inclusive).
  bool contains(DateTime date) {
    return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
        (date.isBefore(end) || date.isAtSameMomentAs(end));
  }

  /// Duration in days.
  int get durationInDays => end.difference(start).inDays + 1;

  /// Human-friendly display label for UI headers or filter chips.
  String get label {
    switch (preset) {
      case DateRangePreset.today:
        return 'Today';
      case DateRangePreset.yesterday:
        return 'Yesterday';
      case DateRangePreset.thisMonth:
        return DateFormat('MMMM yyyy').format(start);
      case DateRangePreset.lastMonth:
        return DateFormat('MMMM yyyy').format(start);
      case DateRangePreset.thisYear:
        return '${start.year}';
      case DateRangePreset.allTime:
        return 'All Time';
      case DateRangePreset.thisWeek:
        return 'This Week';
      case DateRangePreset.custom:
        final startFmt = DateFormat('MMM d').format(start);
        final endFmt = DateFormat('MMM d, yyyy').format(end);
        return '$startFmt – $endFmt';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end &&
          preset == other.preset;

  @override
  int get hashCode => Object.hash(start, end, preset);

  @override
  String toString() => '$label ($start to $end)';
}

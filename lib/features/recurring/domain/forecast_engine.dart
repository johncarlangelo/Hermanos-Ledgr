import 'package:hermanos_ledgr/features/recurring/domain/recurring_model.dart';

/// Single scheduled event occurrence on a given forecast date (Task 8.9).
class ScheduledOccurrence {
  final DateTime date;
  final RecurringModel rule;
  final double amount;
  final bool isExpense;

  const ScheduledOccurrence({
    required this.date,
    required this.rule,
    required this.amount,
    required this.isExpense,
  });
}

/// Daily forecast data point for timeline graphing (Task 8.8).
class ForecastDataPoint {
  final DateTime date;
  final int dayIndex;
  final double projectedBalance;
  final List<ScheduledOccurrence> events;

  const ForecastDataPoint({
    required this.date,
    required this.dayIndex,
    required this.projectedBalance,
    this.events = const [],
  });
}

/// Complete cashflow forecast calculation over a chosen time horizon (Task 8.7).
class CashflowForecast {
  final double startingBalance;
  final double endingBalance;
  final double totalIncome;
  final double totalExpense;
  final int daysHorizon;
  final List<ForecastDataPoint> dataPoints;
  final List<ScheduledOccurrence> upcomingOccurrences;

  const CashflowForecast({
    required this.startingBalance,
    required this.endingBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.daysHorizon,
    required this.dataPoints,
    required this.upcomingOccurrences,
  });

  double get netChange => endingBalance - startingBalance;
  bool get isPositiveNet => netChange >= 0;
}

/// Calculation engine generating cashflow projections and upcoming event schedules.
class ForecastEngine {
  ForecastEngine._();

  /// Computes cashflow timeline and scheduled occurrences over [daysHorizon] days.
  static CashflowForecast calculate({
    required double startingBalance,
    required List<RecurringModel> rules,
    int daysHorizon = 30,
    DateTime? startDate,
  }) {
    final now = startDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = today.add(Duration(days: daysHorizon));

    final List<ScheduledOccurrence> occurrences = [];

    // 1. Gather all occurrences within the horizon window for active rules
    for (final rule in rules) {
      if (!rule.isActive) continue;

      var current = rule.nextDueDate;
      // If due date was before today, start checking from today
      while (current.isBefore(today)) {
        current = rule.frequency.calculateNextDate(current);
      }

      int guard = 0;
      while ((current.isBefore(endDate) || _isSameDay(current, endDate)) && guard < 100) {
        guard++;
        occurrences.add(
          ScheduledOccurrence(
            date: current,
            rule: rule,
            amount: rule.amount,
            isExpense: rule.isExpense,
          ),
        );
        current = rule.frequency.calculateNextDate(current);
      }
    }

    // Sort chronologically
    occurrences.sort((a, b) => a.date.compareTo(b.date));

    // 2. Day-by-day cashflow simulation
    double runningBalance = startingBalance;
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    final List<ForecastDataPoint> points = [];

    // Map events by day offset
    final Map<int, List<ScheduledOccurrence>> eventsByDay = {};
    for (final occ in occurrences) {
      final dayOffset = DateTime(occ.date.year, occ.date.month, occ.date.day)
          .difference(today)
          .inDays;
      if (dayOffset >= 0 && dayOffset <= daysHorizon) {
        eventsByDay.putIfAbsent(dayOffset, () => []).add(occ);
      }
    }

    for (int day = 0; day <= daysHorizon; day++) {
      final date = today.add(Duration(days: day));
      final dayEvents = eventsByDay[day] ?? const [];

      for (final ev in dayEvents) {
        if (ev.isExpense) {
          runningBalance -= ev.amount;
          totalExpense += ev.amount;
        } else {
          runningBalance += ev.amount;
          totalIncome += ev.amount;
        }
      }

      points.add(
        ForecastDataPoint(
          date: date,
          dayIndex: day,
          projectedBalance: runningBalance,
          events: dayEvents,
        ),
      );
    }

    return CashflowForecast(
      startingBalance: startingBalance,
      endingBalance: runningBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      daysHorizon: daysHorizon,
      dataPoints: points,
      upcomingOccurrences: occurrences,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

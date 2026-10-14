import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/core/models/date_range.dart';
import 'package:hermanos_ledgr/core/models/money.dart';
import 'package:hermanos_ledgr/core/models/result.dart';
import 'package:hermanos_ledgr/core/utils/date_formatter.dart';

void main() {
  group('Money Value Object', () {
    test('Basic creation and formatting', () {
      const m1 = Money(1500.50);
      expect(m1.amount, 1500.50);
      expect(m1.formatted, '₱1,500.50');
      expect(m1.isPositive, isTrue);
      expect(m1.isZero, isFalse);
      expect(m1.isNegative, isFalse);

      const mZero = Money.zero();
      expect(mZero.isZero, isTrue);
      expect(mZero.amount, 0.0);
    });

    test('Arithmetic operations (+, -, *, /)', () {
      const a = Money(100.0);
      const b = Money(50.0);

      expect((a + b).amount, 150.0);
      expect((a - b).amount, 50.0);
      expect((a * 2).amount, 200.0);
      expect((a / 2).amount, 50.0);
      expect((-a).amount, -100.0);
    });

    test('Comparisons and equality', () {
      const a = Money(100.0);
      const b = Money(200.0);
      const c = Money(100.0);

      expect(a < b, isTrue);
      expect(b > a, isTrue);
      expect(a == c, isTrue);
      expect(a <= c, isTrue);
      expect(a >= c, isTrue);
    });
  });

  group('DateRange Value Object', () {
    test('Today preset contains current moment', () {
      final today = DateRange.today();
      final now = DateTime.now();

      expect(today.contains(now), isTrue);
      expect(today.preset, DateRangePreset.today);
      expect(today.label, 'Today');
    });

    test('ThisMonth preset starts on 1st day of month', () {
      final thisMonth = DateRange.thisMonth();
      final now = DateTime.now();

      expect(thisMonth.start.day, 1);
      expect(thisMonth.start.month, now.month);
      expect(thisMonth.contains(now), isTrue);
    });
  });

  group('DateFormatter Utility', () {
    test('Relative formatting returns Today for now', () {
      final now = DateTime.now();
      expect(DateFormatter.relativeDay(now), 'Today');
    });

    test('Relative formatting returns Yesterday for 24h prior', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.relativeDay(yesterday), 'Yesterday');
    });

    test('isSameDay accurately tests same calendar dates', () {
      final a = DateTime(2026, 10, 14, 9, 30);
      final b = DateTime(2026, 10, 14, 18, 45);
      final c = DateTime(2026, 10, 15, 9, 30);

      expect(DateFormatter.isSameDay(a, b), isTrue);
      expect(DateFormatter.isSameDay(a, c), isFalse);
    });
  });

  group('Result<T> Error Handling', () {
    test('Success returns data', () {
      const Result<int> res = Success(42);
      expect(res.isSuccess, isTrue);
      expect(res.isFailure, isFalse);
      expect(res.dataOrNull, 42);
      expect(res.errorOrNull, isNull);
    });

    test('Failure returns message', () {
      const Result<int> res = Failure('Database locked');
      expect(res.isSuccess, isFalse);
      expect(res.isFailure, isTrue);
      expect(res.dataOrNull, isNull);
      expect(res.errorOrNull, 'Database locked');
    });
  });
}

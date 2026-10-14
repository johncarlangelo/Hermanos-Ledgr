import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/core/constants/app_constants.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';

/// Immutable value object representing a monetary amount in Philippine Pesos.
/// Enforces tabular figures typography and consistent mathematical operations.
@immutable
class Money implements Comparable<Money> {
  final double amount;
  final String currency;

  const Money(
    this.amount, {
    this.currency = AppConstants.currencySymbol,
  });

  const Money.zero([String currency = AppConstants.currencySymbol])
      : this(0.0, currency: currency);

  bool get isZero => amount == 0.0;
  bool get isPositive => amount > 0.0;
  bool get isNegative => amount < 0.0;

  /// Formats the money with currency symbol (e.g., "₱1,250.00").
  String get formatted => CurrencyFormatter.format(amount);

  /// Compact representation (e.g. "₱1.2K").
  String get formattedCompact => CurrencyFormatter.formatCompact(amount);

  /// Signed representation (e.g. "+₱1,250.00" or "-₱450.00").
  String get formattedSigned => CurrencyFormatter.format(amount, showSign: true);

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(amount + other.amount, currency: currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(amount - other.amount, currency: currency);
  }

  Money operator *(num factor) {
    return Money(amount * factor, currency: currency);
  }

  Money operator /(num divisor) {
    if (divisor == 0) throw ArgumentError('Cannot divide money by zero');
    return Money(amount / divisor, currency: currency);
  }

  Money operator -() => Money(-amount, currency: currency);

  bool operator <(Money other) {
    _assertSameCurrency(other);
    return amount < other.amount;
  }

  bool operator <=(Money other) {
    _assertSameCurrency(other);
    return amount <= other.amount;
  }

  bool operator >(Money other) {
    _assertSameCurrency(other);
    return amount > other.amount;
  }

  bool operator >=(Money other) {
    _assertSameCurrency(other);
    return amount >= other.amount;
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return amount.compareTo(other.amount);
  }

  void _assertSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError(
        'Currency mismatch: cannot operate between $currency and ${other.currency}',
      );
    }
  }

  /// Applies tabular figures font feature so numbers do not jump during animation.
  static TextStyle applyTabularFigures(TextStyle base) {
    return base.copyWith(
      fontFeatures: [
        ...?base.fontFeatures,
        const FontFeature.tabularFigures(),
      ],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          currency == other.currency;

  @override
  int get hashCode => Object.hash(amount, currency);

  @override
  String toString() => formatted;
}

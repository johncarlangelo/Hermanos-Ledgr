import 'package:drift/drift.dart';

/// Drift SQLite table for Recurring Transactions and Subscriptions (Phase 8).
class RecurringTransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'expense', 'income', 'transfer'
  TextColumn get categoryId => text()();
  TextColumn get categoryName => text()();
  TextColumn get accountId => text()();
  TextColumn get accountName => text()();
  TextColumn get frequency => text()(); // 'daily', 'weekly', 'biweekly', 'monthly', 'yearly'
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get nextDueDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart';

/// Drift SQLite table for Debts and Receivables (Phase 7 - Utang / Pa-utang).
class DebtsTable extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // 'debt' (payable) or 'receivable'
  TextColumn get personName => text()();
  RealColumn get originalAmount => real()();
  RealColumn get remainingAmount => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get isSettled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

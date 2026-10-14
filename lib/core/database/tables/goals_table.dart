import 'package:drift/drift.dart';

/// Drift SQLite table for Savings Goals (Phase 6).
class GoalsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  IntColumn get iconCode => integer().nullable()();
  IntColumn get colorValue => integer().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

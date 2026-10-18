import 'package:drift/drift.dart';

/// SQLite table for Financial Quick Notes / Scratchpad (Task 12.7, ARCHITECTURE.md).
@DataClassName('Note')
class NotesTable extends Table {
  @override
  String get tableName => 'notes';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileId => text().withDefault(const Constant('default'))();
  TextColumn get content => text()();
  TextColumn get tag => text().nullable()(); // 'Expense', 'Reminder', 'Idea', 'General'
  RealColumn get amount => real().nullable()(); // optional detected or attached amount
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

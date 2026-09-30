import 'package:drift/drift.dart';

class BudgetsTable extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  TextColumn get categoryName => text()();
  RealColumn get monthlyLimit => real()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

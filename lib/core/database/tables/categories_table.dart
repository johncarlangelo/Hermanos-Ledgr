import 'package:drift/drift.dart';

class CategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get iconCode => integer()();
  IntColumn get colorValue => integer()();
  BoolColumn get isExpense => boolean().withDefault(const Constant(true))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart';

class AccountsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // eWallet, bank, cash, credit
  RealColumn get balance => real()();
  IntColumn get iconCode => integer()();
  IntColumn get colorValue => integer()();
  TextColumn get institution => text()();
  RealColumn get monthlyChange => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

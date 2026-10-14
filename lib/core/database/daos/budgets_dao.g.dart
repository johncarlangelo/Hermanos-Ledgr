// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budgets_dao.dart';

// ignore_for_file: type=lint
mixin _$BudgetsDaoMixin on DatabaseAccessor<AppDatabase> {
  $BudgetsTableTable get budgetsTable => attachedDatabase.budgetsTable;
  BudgetsDaoManager get managers => BudgetsDaoManager(this);
}

class BudgetsDaoManager {
  final _$BudgetsDaoMixin _db;
  BudgetsDaoManager(this._db);
  $$BudgetsTableTableTableManager get budgetsTable =>
      $$BudgetsTableTableTableManager(_db.attachedDatabase, _db.budgetsTable);
}

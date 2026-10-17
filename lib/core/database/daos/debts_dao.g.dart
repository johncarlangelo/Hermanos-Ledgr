// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debts_dao.dart';

// ignore_for_file: type=lint
mixin _$DebtsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DebtsTableTable get debtsTable => attachedDatabase.debtsTable;
  DebtsDaoManager get managers => DebtsDaoManager(this);
}

class DebtsDaoManager {
  final _$DebtsDaoMixin _db;
  DebtsDaoManager(this._db);
  $$DebtsTableTableTableManager get debtsTable =>
      $$DebtsTableTableTableManager(_db.attachedDatabase, _db.debtsTable);
}

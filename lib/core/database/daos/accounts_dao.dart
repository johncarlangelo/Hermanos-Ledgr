import 'package:drift/drift.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/tables/accounts_table.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [AccountsTable])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
  AccountsDao(super.db);

  Stream<List<AccountsTableData>> watchAllAccounts() => select(accountsTable).watch();

  Future<List<AccountsTableData>> getAllAccounts() => select(accountsTable).get();

  Future<AccountsTableData?> getAccountById(String id) =>
      (select(accountsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertOrUpdateAccount(AccountsTableCompanion account) =>
      into(accountsTable).insert(account, mode: InsertMode.insertOrReplace);

  Future<int> updateBalance(String id, double delta) async {
    final acc = await getAccountById(id);
    if (acc == null) return 0;
    return (update(accountsTable)..where((t) => t.id.equals(id))).write(
      AccountsTableCompanion(balance: Value(acc.balance + delta)),
    );
  }

  Future<int> deleteAccount(String id) =>
      (delete(accountsTable)..where((t) => t.id.equals(id))).go();
}

import 'package:drift/drift.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/tables/transactions_table.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [TransactionsTable])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Stream<List<TransactionsTableData>> watchAllTransactions() =>
      (select(transactionsTable)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Future<List<TransactionsTableData>> getAllTransactions() =>
      (select(transactionsTable)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

  Stream<List<TransactionsTableData>> watchTransactionsByAccount(String accountId) =>
      (select(transactionsTable)
            ..where((t) => t.accountId.equals(accountId) | t.destinationAccountId.equals(accountId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<List<TransactionsTableData>> getTransactionsByDateRange(DateTime start, DateTime end) =>
      (select(transactionsTable)
            ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerOrEqualValue(end))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<int> insertTransaction(TransactionsTableCompanion tx) =>
      into(transactionsTable).insert(tx, mode: InsertMode.insertOrReplace);

  Future<int> deleteTransaction(String id) =>
      (delete(transactionsTable)..where((t) => t.id.equals(id))).go();
}

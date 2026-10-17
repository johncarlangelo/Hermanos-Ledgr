import 'package:drift/drift.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/tables/debts_table.dart';

part 'debts_dao.g.dart';

@DriftAccessor(tables: [DebtsTable])
class DebtsDao extends DatabaseAccessor<AppDatabase> with _$DebtsDaoMixin {
  DebtsDao(super.db);

  Stream<List<DebtsTableData>> watchAllDebts() =>
      (select(debtsTable)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Future<List<DebtsTableData>> getAllDebts() =>
      (select(debtsTable)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Future<DebtsTableData?> getDebtById(String id) =>
      (select(debtsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertOrUpdateDebt(DebtsTableCompanion debt) =>
      into(debtsTable).insert(debt, mode: InsertMode.insertOrReplace);

  Future<int> recordPayment(String id, double paymentAmount) async {
    final record = await getDebtById(id);
    if (record == null) return 0;

    final newRemaining = (record.remainingAmount - paymentAmount).clamp(0.0, record.originalAmount);
    final isDone = newRemaining <= 0;

    return (update(debtsTable)..where((t) => t.id.equals(id))).write(
      DebtsTableCompanion(
        remainingAmount: Value(newRemaining),
        isSettled: Value(isDone),
      ),
    );
  }

  Future<int> deleteDebt(String id) =>
      (delete(debtsTable)..where((t) => t.id.equals(id))).go();
}

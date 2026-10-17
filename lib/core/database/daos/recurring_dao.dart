import 'package:drift/drift.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/tables/recurring_table.dart';

part 'recurring_dao.g.dart';

@DriftAccessor(tables: [RecurringTransactionsTable])
class RecurringDao extends DatabaseAccessor<AppDatabase> with _$RecurringDaoMixin {
  RecurringDao(super.db);

  Stream<List<RecurringTransactionsTableData>> watchAllRecurring() =>
      (select(recurringTransactionsTable)..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)])).watch();

  Future<List<RecurringTransactionsTableData>> getAllRecurring() =>
      (select(recurringTransactionsTable)..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)])).get();

  Future<RecurringTransactionsTableData?> getRecurringById(String id) =>
      (select(recurringTransactionsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertOrUpdateRecurring(RecurringTransactionsTableCompanion item) =>
      into(recurringTransactionsTable).insert(item, mode: InsertMode.insertOrReplace);

  Future<bool> updateRecurring(RecurringTransactionsTableCompanion item) =>
      update(recurringTransactionsTable).replace(item);

  Future<int> toggleActive(String id, bool isActive) =>
      (update(recurringTransactionsTable)..where((t) => t.id.equals(id)))
          .write(RecurringTransactionsTableCompanion(isActive: Value(isActive)));

  Future<int> updateNextDueDate(String id, DateTime nextDueDate) =>
      (update(recurringTransactionsTable)..where((t) => t.id.equals(id)))
          .write(RecurringTransactionsTableCompanion(nextDueDate: Value(nextDueDate)));

  Future<int> deleteRecurring(String id) =>
      (delete(recurringTransactionsTable)..where((t) => t.id.equals(id))).go();
}

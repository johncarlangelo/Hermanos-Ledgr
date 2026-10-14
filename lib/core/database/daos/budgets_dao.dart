import 'package:drift/drift.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/tables/budgets_table.dart';

part 'budgets_dao.g.dart';

@DriftAccessor(tables: [BudgetsTable])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  BudgetsDao(super.db);

  Stream<List<BudgetsTableData>> watchAllBudgets() => select(budgetsTable).watch();

  Future<List<BudgetsTableData>> getAllBudgets() => select(budgetsTable).get();

  Future<BudgetsTableData?> getBudgetByCategory(String categoryId) =>
      (select(budgetsTable)..where((t) => t.categoryId.equals(categoryId))).getSingleOrNull();

  Future<int> upsertBudget(BudgetsTableCompanion budget) =>
      into(budgetsTable).insert(budget, mode: InsertMode.insertOrReplace);

  Future<int> deleteBudget(String id) =>
      (delete(budgetsTable)..where((t) => t.id.equals(id))).go();
}

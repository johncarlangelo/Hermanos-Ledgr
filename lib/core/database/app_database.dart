import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/core/database/tables/accounts_table.dart';
import 'package:hermanos_ledgr/core/database/tables/budgets_table.dart';
import 'package:hermanos_ledgr/core/database/tables/categories_table.dart';
import 'package:hermanos_ledgr/core/database/tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  AccountsTable,
  TransactionsTable,
  BudgetsTable,
  CategoriesTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(e ??
            driftDatabase(
              name: 'hermanos_ledgr',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await seedCategories();
        },
        beforeOpen: (details) async {
          final cats = await select(categoriesTable).get();
          if (cats.isEmpty) {
            await seedCategories();
          }
          // Purge lingering mock data from early pre-alpha testing
          await (delete(transactionsTable)..where((t) => t.id.like('tx_ai_%') | t.id.isIn(['tx_1', 'tx_2', 'tx_3', 'tx_4', 'tx_5', 'tx_6', 'tx_7']))).go();
          await (delete(budgetsTable)..where((t) => t.id.isIn(['bg_food', 'bg_groceries', 'bg_utilities', 'bg_transport', 'bg_entertainment']))).go();

          // If there are zero transactions, reset all account balances to 0.0
          final allTxs = await select(transactionsTable).get();
          if (allTxs.isEmpty) {
            await update(accountsTable).write(
              const AccountsTableCompanion(balance: Value(0.0), monthlyChange: Value(0.0)),
            );
          }
        },
      );

  Future<void> seedDefaults() async {
    await seedCategories();
  }

  Future<void> seedCategories() async {
    for (final cat in CategoryDefaults.defaultCategories) {
      await into(categoriesTable).insert(
        CategoriesTableCompanion.insert(
          id: cat.id,
          name: cat.name,
          iconCode: cat.icon.codePoint,
          colorValue: cat.color.toARGB32(),
          isExpense: Value(cat.isExpense),
          isCustom: const Value(false),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  Future<void> clearAndReseed() async {
    await delete(transactionsTable).go();
    await delete(accountsTable).go();
    await delete(budgetsTable).go();
    await delete(categoriesTable).go();
    await seedCategories();
  }
}

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/core/database/daos/accounts_dao.dart';
import 'package:hermanos_ledgr/core/database/daos/budgets_dao.dart';
import 'package:hermanos_ledgr/core/database/daos/categories_dao.dart';
import 'package:hermanos_ledgr/core/database/daos/chat_dao.dart';
import 'package:hermanos_ledgr/core/database/daos/debts_dao.dart';
import 'package:hermanos_ledgr/core/database/daos/goals_dao.dart';
import 'package:hermanos_ledgr/core/database/daos/notes_dao.dart';
import 'package:hermanos_ledgr/core/database/daos/recurring_dao.dart';
import 'package:hermanos_ledgr/core/database/daos/transactions_dao.dart';
import 'package:hermanos_ledgr/core/database/tables/accounts_table.dart';
import 'package:hermanos_ledgr/core/database/tables/budgets_table.dart';
import 'package:hermanos_ledgr/core/database/tables/categories_table.dart';
import 'package:hermanos_ledgr/core/database/tables/chat_messages_table.dart';
import 'package:hermanos_ledgr/core/database/tables/debts_table.dart';
import 'package:hermanos_ledgr/core/database/tables/goals_table.dart';
import 'package:hermanos_ledgr/core/database/tables/notes_table.dart';
import 'package:hermanos_ledgr/core/database/tables/recurring_table.dart';
import 'package:hermanos_ledgr/core/database/tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    AccountsTable,
    TransactionsTable,
    BudgetsTable,
    CategoriesTable,
    GoalsTable,
    DebtsTable,
    RecurringTransactionsTable,
    ChatMessagesTable,
    NotesTable,
  ],
  daos: [
    AccountsDao,
    TransactionsDao,
    BudgetsDao,
    CategoriesDao,
    GoalsDao,
    DebtsDao,
    RecurringDao,
    ChatDao,
    NotesDao,
  ],
)
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
    await delete(goalsTable).go();
    await delete(debtsTable).go();
    await delete(recurringTransactionsTable).go();
    await delete(categoriesTable).go();
    await seedCategories();
  }
}

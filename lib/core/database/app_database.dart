import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:hermanos_ledgr/core/constants/account_defaults.dart';
import 'package:hermanos_ledgr/core/constants/budget_defaults.dart';
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await seedCategories();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(
              recurringTransactionsTable,
              recurringTransactionsTable.enableNotifications,
            );
          }
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
    await seedStarterAccounts();
    await seedBudgets();
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

  Future<void> seedStarterAccounts() async {
    for (final acc in AccountDefaults.starterCleanAccounts) {
      await into(accountsTable).insert(
        AccountsTableCompanion.insert(
          id: acc.id,
          name: acc.name,
          type: acc.type.name,
          balance: acc.balance,
          iconCode: acc.icon.codePoint,
          colorValue: acc.color.toARGB32(),
          institution: acc.institution ?? '',
          monthlyChange: Value(acc.monthlyChange),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  Future<void> seedBudgets() async {
    final now = DateTime.now();
    for (final b in BudgetDefaults.defaultCategoryBudgets) {
      await into(budgetsTable).insert(
        BudgetsTableCompanion.insert(
          id: 'budget_${b.categoryId}',
          categoryId: b.categoryId,
          categoryName: b.categoryName,
          monthlyLimit: b.monthlyLimit,
          month: now.month,
          year: now.year,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  Future<void> clearAndReseed() async {
    await delete(notesTable).go();
    await delete(chatMessagesTable).go();
    await delete(recurringTransactionsTable).go();
    await delete(debtsTable).go();
    await delete(goalsTable).go();
    await delete(budgetsTable).go();
    await delete(transactionsTable).go();
    await delete(accountsTable).go();
    await delete(categoriesTable).go();
    await seedCategories();
    await seedStarterAccounts();
    await seedBudgets();
  }
}

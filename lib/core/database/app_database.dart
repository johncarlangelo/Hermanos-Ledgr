import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart' show Icons, Color;
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
          await seedDefaults();
        },
        beforeOpen: (details) async {
          final accounts = await select(accountsTable).get();
          if (accounts.isEmpty) {
            await seedDefaults();
          }
        },
      );

  Future<void> seedDefaults() async {
    // 1. Seed Categories
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

    // 2. Seed Starter Accounts
    await into(accountsTable).insert(
      AccountsTableCompanion.insert(
        id: 'acc_gcash',
        name: 'GCash',
        type: 'eWallet',
        balance: 14850.50,
        iconCode: Icons.account_balance_wallet_rounded.codePoint,
        colorValue: const Color(0xFF005CEE).toARGB32(),
        institution: 'Mynt',
        monthlyChange: const Value(1200.0),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(accountsTable).insert(
      AccountsTableCompanion.insert(
        id: 'acc_bdo',
        name: 'BDO Savings',
        type: 'bank',
        balance: 85420.00,
        iconCode: Icons.account_balance_rounded.codePoint,
        colorValue: const Color(0xFF0038A8).toARGB32(),
        institution: 'BDO Unibank',
        monthlyChange: const Value(15000.0),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(accountsTable).insert(
      AccountsTableCompanion.insert(
        id: 'acc_cash',
        name: 'Cash Wallet',
        type: 'cash',
        balance: 4350.00,
        iconCode: Icons.payments_rounded.codePoint,
        colorValue: const Color(0xFF00897B).toARGB32(),
        institution: 'Cash',
        monthlyChange: const Value(-450.0),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(accountsTable).insert(
      AccountsTableCompanion.insert(
        id: 'acc_maya',
        name: 'Maya',
        type: 'eWallet',
        balance: 12600.25,
        iconCode: Icons.wallet_rounded.codePoint,
        colorValue: const Color(0xFF00D166).toARGB32(),
        institution: 'Maya Philippines',
        monthlyChange: const Value(800.0),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(accountsTable).insert(
      AccountsTableCompanion.insert(
        id: 'acc_bpi_cc',
        name: 'BPI Platinum Card',
        type: 'creditCard',
        balance: -8450.00,
        iconCode: Icons.credit_card_rounded.codePoint,
        colorValue: const Color(0xFFB71C1C).toARGB32(),
        institution: 'Bank of the Philippine Islands',
        monthlyChange: const Value(-2100.0),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    // 3. Seed Starter Transactions
    final now = DateTime.now();
    await into(transactionsTable).insert(
      TransactionsTableCompanion.insert(
        id: 'tx_1',
        title: 'Jollibee Chickenjoy Meal',
        amount: 285.00,
        type: 'expense',
        categoryId: 'food',
        categoryName: 'Food & Dining',
        categoryIconCode: Icons.restaurant_rounded.codePoint,
        categoryColorValue: const Color(0xFFF57C00).toARGB32(),
        accountId: 'acc_gcash',
        accountName: 'GCash',
        date: now.subtract(const Duration(hours: 2)),
        note: const Value('Lunch with colleagues'),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(transactionsTable).insert(
      TransactionsTableCompanion.insert(
        id: 'tx_2',
        title: 'Puregold Supermarket',
        amount: 2450.00,
        type: 'expense',
        categoryId: 'groceries',
        categoryName: 'Groceries',
        categoryIconCode: Icons.shopping_cart_rounded.codePoint,
        categoryColorValue: const Color(0xFF43A047).toARGB32(),
        accountId: 'acc_bdo',
        accountName: 'BDO Savings',
        date: now.subtract(const Duration(hours: 5)),
        note: const Value('Weekly essentials & snacks'),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(transactionsTable).insert(
      TransactionsTableCompanion.insert(
        id: 'tx_3',
        title: 'Angkas Ride to Ortigas',
        amount: 145.00,
        type: 'expense',
        categoryId: 'transport',
        categoryName: 'Transportation',
        categoryIconCode: Icons.directions_bus_rounded.codePoint,
        categoryColorValue: const Color(0xFF1E88E5).toARGB32(),
        accountId: 'acc_gcash',
        accountName: 'GCash',
        date: now.subtract(const Duration(days: 1, hours: 3)),
        note: const Value('Morning commute'),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(transactionsTable).insert(
      TransactionsTableCompanion.insert(
        id: 'tx_4',
        title: 'Client Project Milestone',
        amount: 28000.00,
        type: 'income',
        categoryId: 'freelance',
        categoryName: 'Side Hustle',
        categoryIconCode: Icons.laptop_chromebook_rounded.codePoint,
        categoryColorValue: const Color(0xFF00897B).toARGB32(),
        accountId: 'acc_bdo',
        accountName: 'BDO Savings',
        date: now.subtract(const Duration(days: 2)),
        note: const Value('Mobile app consulting phase 1'),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(transactionsTable).insert(
      TransactionsTableCompanion.insert(
        id: 'tx_5',
        title: 'Meralco Electric Bill',
        amount: 3820.00,
        type: 'expense',
        categoryId: 'utilities',
        categoryName: 'Utilities & Bills',
        categoryIconCode: Icons.bolt_rounded.codePoint,
        categoryColorValue: const Color(0xFFFBC02D).toARGB32(),
        accountId: 'acc_maya',
        accountName: 'Maya',
        date: now.subtract(const Duration(days: 3)),
        note: const Value('September statement'),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(transactionsTable).insert(
      TransactionsTableCompanion.insert(
        id: 'tx_6',
        title: 'Netflix Subscription',
        amount: 549.00,
        type: 'expense',
        categoryId: 'entertainment',
        categoryName: 'Entertainment',
        categoryIconCode: Icons.movie_filter_rounded.codePoint,
        categoryColorValue: const Color(0xFF00ACC1).toARGB32(),
        accountId: 'acc_bpi_cc',
        accountName: 'BPI Platinum Card',
        date: now.subtract(const Duration(days: 4)),
        note: const Value('Monthly premium'),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(transactionsTable).insert(
      TransactionsTableCompanion.insert(
        id: 'tx_7',
        title: 'Transfer to GCash',
        amount: 5000.00,
        type: 'transfer',
        categoryId: 'other_expense',
        categoryName: 'Transfer',
        categoryIconCode: Icons.swap_horiz_rounded.codePoint,
        categoryColorValue: const Color(0xFF1565C0).toARGB32(),
        accountId: 'acc_bdo',
        accountName: 'BDO Savings',
        destinationAccountId: const Value('acc_gcash'),
        destinationAccountName: const Value('GCash'),
        date: now.subtract(const Duration(days: 5)),
        note: const Value('E-wallet reload'),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    // 4. Seed Starter Budgets
    await into(budgetsTable).insert(
      BudgetsTableCompanion.insert(
        id: 'bg_food',
        categoryId: 'food',
        categoryName: 'Food & Dining',
        monthlyLimit: 5000.00,
        month: now.month,
        year: now.year,
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(budgetsTable).insert(
      BudgetsTableCompanion.insert(
        id: 'bg_groceries',
        categoryId: 'groceries',
        categoryName: 'Groceries',
        monthlyLimit: 10000.00,
        month: now.month,
        year: now.year,
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(budgetsTable).insert(
      BudgetsTableCompanion.insert(
        id: 'bg_utilities',
        categoryId: 'utilities',
        categoryName: 'Utilities & Bills',
        monthlyLimit: 6000.00,
        month: now.month,
        year: now.year,
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(budgetsTable).insert(
      BudgetsTableCompanion.insert(
        id: 'bg_transport',
        categoryId: 'transport',
        categoryName: 'Transportation',
        monthlyLimit: 3500.00,
        month: now.month,
        year: now.year,
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(budgetsTable).insert(
      BudgetsTableCompanion.insert(
        id: 'bg_entertainment',
        categoryId: 'entertainment',
        categoryName: 'Entertainment',
        monthlyLimit: 2500.00,
        month: now.month,
        year: now.year,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> clearAndReseed() async {
    await delete(transactionsTable).go();
    await delete(accountsTable).go();
    await delete(budgetsTable).go();
    await delete(categoriesTable).go();
    await seedDefaults();
  }
}

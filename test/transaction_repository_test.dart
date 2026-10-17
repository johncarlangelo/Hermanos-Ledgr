import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/database_mappers.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/transactions/data/transaction_repository_impl.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

void main() {
  late AppDatabase db;
  late TransactionRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = TransactionRepositoryImpl(
      db: db,
      transactionsDao: db.transactionsDao,
      accountsDao: db.accountsDao,
    );

    // Seed test accounts: GCash (₱5,000) and BDO (₱10,000)
    await db.accountsDao.insertOrUpdateAccount(
      DatabaseMappers.accountToCompanion(
        const AccountModel(
          id: 'acc_gcash',
          name: 'GCash',
          type: AccountType.eWallet,
          balance: 5000.0,
          icon: Icons.account_balance_wallet_rounded,
          color: Color(0xFF005CEE),
          institution: 'Mynt',
          monthlyChange: 0.0,
        ),
      ),
    );

    await db.accountsDao.insertOrUpdateAccount(
      DatabaseMappers.accountToCompanion(
        const AccountModel(
          id: 'acc_bdo',
          name: 'BDO Savings',
          type: AccountType.bank,
          balance: 10000.0,
          icon: Icons.account_balance_rounded,
          color: Color(0xFF0038A8),
          institution: 'BDO Unibank',
          monthlyChange: 0.0,
        ),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('addTransaction creates expense and subtracts balance atomically', () async {
    final tx = TransactionModel(
      id: 'tx_food_1',
      title: 'Jollibee Meal',
      amount: 250.0,
      type: TransactionType.expense,
      categoryId: 'cat_food',
      categoryName: 'Food & Dining',
      categoryIcon: Icons.restaurant_rounded,
      categoryColor: const Color(0xFFE53935),
      accountId: 'acc_gcash',
      accountName: 'GCash',
      date: DateTime.now(),
    );

    final res = await repository.addTransaction(tx);
    expect(res.isSuccess, isTrue);

    // Verify transaction exists in db
    final txs = await repository.getAllTransactions();
    expect(txs.length, 1);
    expect(txs.first.id, 'tx_food_1');
    expect(txs.first.amount, 250.0);

    // Verify account balance dropped from ₱5000 to ₱4750
    final gcash = await db.accountsDao.getAccountById('acc_gcash');
    expect(gcash?.balance, 4750.0);
  });

  test('addTransaction creates income and adds balance atomically', () async {
    final tx = TransactionModel(
      id: 'tx_salary_1',
      title: 'Freelance Payout',
      amount: 15000.0,
      type: TransactionType.income,
      categoryId: 'cat_salary',
      categoryName: 'Salary',
      categoryIcon: Icons.payments_rounded,
      categoryColor: const Color(0xFF43A047),
      accountId: 'acc_bdo',
      accountName: 'BDO Savings',
      date: DateTime.now(),
    );

    final res = await repository.addTransaction(tx);
    expect(res.isSuccess, isTrue);

    // Verify account balance increased from ₱10000 to ₱25000
    final bdo = await db.accountsDao.getAccountById('acc_bdo');
    expect(bdo?.balance, 25000.0);
  });

  test('addTransaction creates transfer and adjusts both source and destination accounts', () async {
    final tx = TransactionModel(
      id: 'tx_transfer_1',
      title: 'Cash-in to GCash',
      amount: 2000.0,
      type: TransactionType.transfer,
      categoryId: 'cat_transfer',
      categoryName: 'Transfer',
      categoryIcon: Icons.swap_horiz_rounded,
      categoryColor: const Color(0xFF00897B),
      accountId: 'acc_bdo',
      accountName: 'BDO Savings',
      destinationAccountId: 'acc_gcash',
      destinationAccountName: 'GCash',
      date: DateTime.now(),
    );

    final res = await repository.addTransaction(tx);
    expect(res.isSuccess, isTrue);

    // Source BDO dropped from ₱10000 to ₱8000
    final bdo = await db.accountsDao.getAccountById('acc_bdo');
    expect(bdo?.balance, 8000.0);

    // Destination GCash increased from ₱5000 to ₱7000
    final gcash = await db.accountsDao.getAccountById('acc_gcash');
    expect(gcash?.balance, 7000.0);
  });

  test('deleteTransaction rolls back account balance atomically', () async {
    final tx = TransactionModel(
      id: 'tx_expense_del',
      title: 'Coffee',
      amount: 180.0,
      type: TransactionType.expense,
      categoryId: 'cat_food',
      categoryName: 'Food & Dining',
      categoryIcon: Icons.local_cafe_rounded,
      categoryColor: const Color(0xFF8D6E63),
      accountId: 'acc_gcash',
      accountName: 'GCash',
      date: DateTime.now(),
    );

    await repository.addTransaction(tx);
    var gcash = await db.accountsDao.getAccountById('acc_gcash');
    expect(gcash?.balance, 4820.0);

    // Delete transaction
    final delRes = await repository.deleteTransaction(tx);
    expect(delRes.isSuccess, isTrue);

    // Balance refunded back to ₱5000
    gcash = await db.accountsDao.getAccountById('acc_gcash');
    expect(gcash?.balance, 5000.0);

    final txs = await repository.getAllTransactions();
    expect(txs, isEmpty);
  });

  test('updateTransaction recalibrates account balances on amount change', () async {
    final originalTx = TransactionModel(
      id: 'tx_edit_test',
      title: 'Dinner',
      amount: 500.0,
      type: TransactionType.expense,
      categoryId: 'cat_food',
      categoryName: 'Food & Dining',
      categoryIcon: Icons.restaurant_rounded,
      categoryColor: const Color(0xFFE53935),
      accountId: 'acc_gcash',
      accountName: 'GCash',
      date: DateTime.now(),
    );

    await repository.addTransaction(originalTx);
    var gcash = await db.accountsDao.getAccountById('acc_gcash');
    expect(gcash?.balance, 4500.0);

    // Edit transaction: changed amount to ₱800 (difference of -₱300)
    final updatedTx = originalTx.copyWith(amount: 800.0);
    final updateRes = await repository.updateTransaction(
      oldTx: originalTx,
      newTx: updatedTx,
    );
    expect(updateRes.isSuccess, isTrue);

    // Balance reflects new amount ₱800: ₱5000 - ₱800 = ₱4200
    gcash = await db.accountsDao.getAccountById('acc_gcash');
    expect(gcash?.balance, 4200.0);
  });

  test('watchTransactionsByAccount streams transactions only for specified account', () async {
    final txGcash = TransactionModel(
      id: 'tx_g_1',
      title: 'GCash Tx',
      amount: 100.0,
      type: TransactionType.expense,
      categoryId: 'cat_food',
      categoryName: 'Food',
      categoryIcon: Icons.fastfood_rounded,
      categoryColor: Colors.amber,
      accountId: 'acc_gcash',
      accountName: 'GCash',
      date: DateTime.now(),
    );

    final txBdo = TransactionModel(
      id: 'tx_b_1',
      title: 'BDO Tx',
      amount: 200.0,
      type: TransactionType.expense,
      categoryId: 'cat_food',
      categoryName: 'Food',
      categoryIcon: Icons.fastfood_rounded,
      categoryColor: Colors.amber,
      accountId: 'acc_bdo',
      accountName: 'BDO',
      date: DateTime.now(),
    );

    await repository.addTransaction(txGcash);
    await repository.addTransaction(txBdo);

    final gcashTxs = await repository.watchTransactionsByAccount('acc_gcash').first;
    expect(gcashTxs.length, 1);
    expect(gcashTxs.first.id, 'tx_g_1');
  });
}

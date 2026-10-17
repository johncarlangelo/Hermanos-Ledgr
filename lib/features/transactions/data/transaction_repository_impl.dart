import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/daos/accounts_dao.dart';
import 'package:hermanos_ledgr/core/database/daos/transactions_dao.dart';
import 'package:hermanos_ledgr/core/database/database_mappers.dart';
import 'package:hermanos_ledgr/core/models/result.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_repository.dart';

/// Concrete implementation of [TransactionRepository] utilizing Drift SQLite DAOs
/// with atomic database transactions guaranteeing balance consistency.
class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase db;
  final TransactionsDao transactionsDao;
  final AccountsDao accountsDao;

  TransactionRepositoryImpl({
    required this.db,
    required this.transactionsDao,
    required this.accountsDao,
  });

  @override
  Stream<List<TransactionModel>> watchAllTransactions() {
    return transactionsDao
        .watchAllTransactions()
        .map((rows) => rows.map(DatabaseMappers.transactionFromDrift).toList());
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    final rows = await transactionsDao.getAllTransactions();
    return rows.map(DatabaseMappers.transactionFromDrift).toList();
  }

  @override
  Stream<List<TransactionModel>> watchTransactionsByAccount(String accountId) {
    return transactionsDao
        .watchTransactionsByAccount(accountId)
        .map((rows) => rows.map(DatabaseMappers.transactionFromDrift).toList());
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final rows = await transactionsDao.getTransactionsByDateRange(start, end);
    return rows.map(DatabaseMappers.transactionFromDrift).toList();
  }

  @override
  Future<Result<void>> addTransaction(TransactionModel tx) async {
    try {
      await db.transaction(() async {
        // 1. Insert transaction record
        await transactionsDao.insertTransaction(DatabaseMappers.transactionToCompanion(tx));

        // 2. Adjust account balances atomically
        if (tx.type == TransactionType.expense) {
          await accountsDao.updateBalance(tx.accountId, -tx.amount);
        } else if (tx.type == TransactionType.income) {
          await accountsDao.updateBalance(tx.accountId, tx.amount);
        } else if (tx.type == TransactionType.transfer) {
          await accountsDao.updateBalance(tx.accountId, -tx.amount);
          if (tx.destinationAccountId != null) {
            await accountsDao.updateBalance(tx.destinationAccountId!, tx.amount);
          }
        }
      });
      return const Success(null);
    } catch (e) {
      return Failure('Failed to add transaction: $e');
    }
  }

  @override
  Future<Result<void>> updateTransaction({
    required TransactionModel oldTx,
    required TransactionModel newTx,
  }) async {
    try {
      await db.transaction(() async {
        // 1. Insert / replace updated transaction record
        await transactionsDao.insertTransaction(DatabaseMappers.transactionToCompanion(newTx));

        // 2. Revert old transaction amounts
        if (oldTx.type == TransactionType.expense) {
          await accountsDao.updateBalance(oldTx.accountId, oldTx.amount);
        } else if (oldTx.type == TransactionType.income) {
          await accountsDao.updateBalance(oldTx.accountId, -oldTx.amount);
        } else if (oldTx.type == TransactionType.transfer) {
          await accountsDao.updateBalance(oldTx.accountId, oldTx.amount);
          if (oldTx.destinationAccountId != null) {
            await accountsDao.updateBalance(oldTx.destinationAccountId!, -oldTx.amount);
          }
        }

        // 3. Apply new transaction amounts
        if (newTx.type == TransactionType.expense) {
          await accountsDao.updateBalance(newTx.accountId, -newTx.amount);
        } else if (newTx.type == TransactionType.income) {
          await accountsDao.updateBalance(newTx.accountId, newTx.amount);
        } else if (newTx.type == TransactionType.transfer) {
          await accountsDao.updateBalance(newTx.accountId, -newTx.amount);
          if (newTx.destinationAccountId != null) {
            await accountsDao.updateBalance(newTx.destinationAccountId!, newTx.amount);
          }
        }
      });
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update transaction: $e');
    }
  }

  @override
  Future<Result<void>> deleteTransaction(TransactionModel tx) async {
    try {
      await db.transaction(() async {
        // 1. Delete transaction record
        await transactionsDao.deleteTransaction(tx.id);

        // 2. Roll back balance adjustments atomically
        if (tx.type == TransactionType.expense) {
          await accountsDao.updateBalance(tx.accountId, tx.amount);
        } else if (tx.type == TransactionType.income) {
          await accountsDao.updateBalance(tx.accountId, -tx.amount);
        } else if (tx.type == TransactionType.transfer) {
          await accountsDao.updateBalance(tx.accountId, tx.amount);
          if (tx.destinationAccountId != null) {
            await accountsDao.updateBalance(tx.destinationAccountId!, -tx.amount);
          }
        }
      });
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete transaction: $e');
    }
  }

  @override
  Future<Result<void>> restoreTransaction(TransactionModel tx) async {
    return addTransaction(tx);
  }

  @override
  Future<Result<void>> clearAllTransactions() async {
    try {
      await db.delete(db.transactionsTable).go();
      return const Success(null);
    } catch (e) {
      return Failure('Failed to clear transactions: $e');
    }
  }
}

/// Riverpod provider for [TransactionRepository]
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(
    db: db,
    transactionsDao: db.transactionsDao,
    accountsDao: db.accountsDao,
  );
});

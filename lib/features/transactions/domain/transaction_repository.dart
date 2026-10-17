import 'package:hermanos_ledgr/core/models/result.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

/// Abstract contract defining transaction persistence and querying operations.
abstract class TransactionRepository {
  /// Stream of all transactions ordered by date descending.
  Stream<List<TransactionModel>> watchAllTransactions();

  /// Retrieve all transactions once.
  Future<List<TransactionModel>> getAllTransactions();

  /// Stream of transactions filtered by a specific account ID (source or destination).
  Stream<List<TransactionModel>> watchTransactionsByAccount(String accountId);

  /// Retrieve transactions within a date range.
  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end);

  /// Add a new transaction (expense, income, transfer) and adjust account balance(s)
  /// atomically inside a single SQLite transaction.
  Future<Result<void>> addTransaction(TransactionModel tx);

  /// Update an existing transaction and adjust account balance(s) atomically by delta.
  Future<Result<void>> updateTransaction({
    required TransactionModel oldTx,
    required TransactionModel newTx,
  });

  /// Delete a transaction and roll back account balance(s) atomically.
  Future<Result<void>> deleteTransaction(TransactionModel tx);

  /// Restore a deleted transaction (e.g. on Undo).
  Future<Result<void>> restoreTransaction(TransactionModel tx);

  /// Clear all transactions from store.
  Future<Result<void>> clearAllTransactions();
}

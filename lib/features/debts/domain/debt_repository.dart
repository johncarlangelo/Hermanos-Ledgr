import 'package:hermanos_ledgr/core/models/result.dart';
import 'debt_model.dart';

/// Abstract repository defining data operations for Debts and Receivables (Phase 7).
abstract class DebtRepository {
  /// Stream of all debts and receivables.
  Stream<List<DebtModel>> watchAllDebts();

  /// Retrieve all debts and receivables once.
  Future<List<DebtModel>> getAllDebts();

  /// Retrieve a single debt or receivable by its ID.
  Future<DebtModel?> getDebtById(String id);

  /// Add a new debt or receivable record.
  Future<Result<void>> addDebt(DebtModel debt);

  /// Update an existing debt or receivable.
  Future<Result<void>> updateDebt(DebtModel debt);

  /// Record a payment towards a debt or receivable.
  /// If [paymentAmount] meets or exceeds remaining balance, it marks [isSettled] = true.
  Future<Result<void>> recordPayment(String id, double paymentAmount);

  /// Delete a debt or receivable by ID.
  Future<Result<void>> deleteDebt(String id);
}

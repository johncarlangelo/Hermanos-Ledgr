import 'package:hermanos_ledgr/core/models/result.dart';
import 'recurring_model.dart';

/// Abstract repository defining data access contracts for Recurring Transactions (Phase 8).
abstract class RecurringRepository {
  /// Stream of all recurring transaction rules.
  Stream<List<RecurringModel>> watchAllRecurring();

  /// Retrieve all recurring transaction rules once.
  Future<List<RecurringModel>> getAllRecurring();

  /// Retrieve a recurring transaction rule by ID.
  Future<RecurringModel?> getRecurringById(String id);

  /// Add a new recurring rule.
  Future<Result<void>> addRecurring(RecurringModel model);

  /// Update an existing recurring rule.
  Future<Result<void>> updateRecurring(RecurringModel model);

  /// Delete a recurring rule by ID.
  Future<Result<void>> deleteRecurring(String id);

  /// Toggle active state of a recurring rule.
  Future<Result<void>> toggleActive(String id, bool isActive);

  /// Advance the next due date of a recurring rule (used by auto-log engine).
  Future<Result<void>> advanceNextDueDate(String id, DateTime newDueDate);
}

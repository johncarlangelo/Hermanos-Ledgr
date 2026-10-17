import 'package:hermanos_ledgr/core/database/app_database.dart';
import 'package:hermanos_ledgr/core/database/daos/recurring_dao.dart';
import 'package:hermanos_ledgr/core/database/database_mappers.dart';
import 'package:hermanos_ledgr/core/models/result.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_model.dart';
import 'package:hermanos_ledgr/features/recurring/domain/recurring_repository.dart';

/// Concrete Drift SQLite implementation of [RecurringRepository] (Task 8.2).
class RecurringRepositoryImpl implements RecurringRepository {
  final AppDatabase db;
  final RecurringDao recurringDao;

  RecurringRepositoryImpl({
    required this.db,
    required this.recurringDao,
  });

  @override
  Stream<List<RecurringModel>> watchAllRecurring() {
    return recurringDao.watchAllRecurring().map(
          (rows) => rows.map(DatabaseMappers.recurringFromDrift).toList(),
        );
  }

  @override
  Future<List<RecurringModel>> getAllRecurring() async {
    final rows = await recurringDao.getAllRecurring();
    return rows.map(DatabaseMappers.recurringFromDrift).toList();
  }

  @override
  Future<RecurringModel?> getRecurringById(String id) async {
    final row = await recurringDao.getRecurringById(id);
    return row != null ? DatabaseMappers.recurringFromDrift(row) : null;
  }

  @override
  Future<Result<void>> addRecurring(RecurringModel model) async {
    try {
      await recurringDao.insertOrUpdateRecurring(DatabaseMappers.recurringToCompanion(model));
      return const Success(null);
    } catch (e) {
      return Failure('Failed to add recurring rule: $e', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateRecurring(RecurringModel model) async {
    try {
      await recurringDao.insertOrUpdateRecurring(DatabaseMappers.recurringToCompanion(model));
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update recurring rule: $e', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteRecurring(String id) async {
    try {
      final rows = await recurringDao.deleteRecurring(id);
      if (rows > 0) {
        return const Success(null);
      }
      return Failure('Recurring rule $id not found');
    } catch (e) {
      return Failure('Failed to delete recurring rule: $e', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> toggleActive(String id, bool isActive) async {
    try {
      await recurringDao.toggleActive(id, isActive);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to toggle recurring rule: $e', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> advanceNextDueDate(String id, DateTime newDueDate) async {
    try {
      await recurringDao.updateNextDueDate(id, newDueDate);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to advance due date: $e', e is Exception ? e : Exception(e.toString()));
    }
  }
}

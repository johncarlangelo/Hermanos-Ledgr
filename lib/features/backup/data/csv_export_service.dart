import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

/// Service generating CSV formatted exports (Task 11.2).
class CsvExportService {
  CsvExportService._();

  /// Escapes CSV field per RFC 4180.
  static String _escapeField(dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    if (str.contains(',') || str.contains('"') || str.contains('\n') || str.contains('\r')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  /// Serializes transaction records into standard CSV string.
  static String generateTransactionsCsv(List<TransactionModel> transactions) {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('ID,Date,Title,Type,Category,Account,DestinationAccount,Amount,Note');

    for (final tx in transactions) {
      final line = [
        _escapeField(tx.id),
        _escapeField(tx.date.toIso8601String()),
        _escapeField(tx.title),
        _escapeField(tx.type.name),
        _escapeField(tx.categoryName),
        _escapeField(tx.accountName),
        _escapeField(tx.destinationAccountName ?? ''),
        _escapeField(tx.amount.toStringAsFixed(2)),
        _escapeField(tx.note ?? ''),
      ].join(',');
      buffer.writeln(line);
    }

    return buffer.toString();
  }

  /// Serializes accounts into CSV string.
  static String generateAccountsCsv(List<AccountModel> accounts) {
    final buffer = StringBuffer();
    buffer.writeln('ID,Name,Type,Institution,Balance,MonthlyChange');

    for (final a in accounts) {
      final line = [
        _escapeField(a.id),
        _escapeField(a.name),
        _escapeField(a.type.name),
        _escapeField(a.institution ?? ''),
        _escapeField(a.balance.toStringAsFixed(2)),
        _escapeField(a.monthlyChange.toStringAsFixed(2)),
      ].join(',');
      buffer.writeln(line);
    }

    return buffer.toString();
  }
}

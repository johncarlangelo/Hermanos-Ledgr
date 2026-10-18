import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:hermanos_ledgr/features/backup/domain/backup_entry.dart';

/// Storage service managing local backup files on device (Tasks 11.3, 11.6).
class BackupStorageService {
  final Directory? _overrideDirectory;

  BackupStorageService([this._overrideDirectory]);

  /// Resolves the dedicated local backup directory.
  Future<Directory> getBackupDirectory() async {
    if (_overrideDirectory != null) {
      if (!await _overrideDirectory.exists()) {
        await _overrideDirectory.create(recursive: true);
      }
      return _overrideDirectory;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(docsDir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Saves an automated daily backup file and triggers retention pruning.
  Future<File> saveAutoBackup(String jsonContent) async {
    final dir = await getBackupDirectory();
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy_MM_dd_HHmmss').format(now);
    final file = File(p.join(dir.path, 'auto_backup_$dateStr.json'));
    await file.writeAsString(jsonContent);

    // Enforce 7-backup retention rule (Task 11.6)
    await pruneAutoBackups(keepLast: 7);

    return file;
  }

  /// Saves a manual backup file.
  Future<File> saveManualBackup(String jsonContent, {String? customName}) async {
    final dir = await getBackupDirectory();
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy_MM_dd_HHmmss').format(now);
    final name = customName?.isNotEmpty == true
        ? customName!
        : 'manual_backup_$dateStr';
    final safeName = name.endsWith('.json') ? name : '$name.json';
    final file = File(p.join(dir.path, safeName));
    await file.writeAsString(jsonContent);
    return file;
  }

  /// Lists all local backups, ordered newest first.
  Future<List<BackupEntry>> listBackups() async {
    final dir = await getBackupDirectory();
    final entities = await dir.list().toList();
    final List<BackupEntry> entries = [];

    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final stat = await entity.stat();
          final fileName = p.basename(entity.path);
          final isAuto = fileName.startsWith('auto_backup_');

          // Attempt to extract total record count from JSON manifest
          int recordCount = 0;
          try {
            final content = await entity.readAsString();
            final decoded = jsonDecode(content);
            if (decoded is Map<String, dynamic>) {
              final txs = decoded['transactionsCount'] ?? (decoded['transactions'] as List?)?.length ?? 0;
              final accs = decoded['accountsCount'] ?? (decoded['accounts'] as List?)?.length ?? 0;
              recordCount = (txs as int) + (accs as int);
            }
          } catch (_) {}

          DateTime fileDate = stat.modified;
          final match = RegExp(r'(\d{4})_(\d{2})_(\d{2})_(\d{2})(\d{2})(\d{2})').firstMatch(fileName);
          if (match != null) {
            try {
              final y = int.parse(match.group(1)!);
              final m = int.parse(match.group(2)!);
              final d = int.parse(match.group(3)!);
              final h = int.parse(match.group(4)!);
              final min = int.parse(match.group(5)!);
              final s = int.parse(match.group(6)!);
              fileDate = DateTime(y, m, d, h, min, s);
            } catch (_) {}
          }

          entries.add(
            BackupEntry(
              filePath: entity.path,
              fileName: fileName,
              fileSizeBytes: stat.size,
              createdAt: fileDate,
              isAutoBackup: isAuto,
              recordCount: recordCount,
            ),
          );
        } catch (_) {}
      }
    }

    // Sort newest first; tie-break on filename descending
    entries.sort((a, b) {
      final cmp = b.createdAt.compareTo(a.createdAt);
      if (cmp != 0) return cmp;
      return b.fileName.compareTo(a.fileName);
    });
    return entries;
  }

  /// Prunes older auto-backups so only the newest [keepLast] remain (Task 11.6).
  Future<int> pruneAutoBackups({int keepLast = 7}) async {
    final all = await listBackups();
    final autoBackups = all.where((b) => b.isAutoBackup).toList();

    if (autoBackups.length <= keepLast) {
      return 0;
    }

    // Sort newest first
    autoBackups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final toDelete = autoBackups.sublist(keepLast);
    int deletedCount = 0;

    for (final entry in toDelete) {
      try {
        final file = File(entry.filePath);
        if (await file.exists()) {
          await file.delete();
          deletedCount++;
        }
      } catch (_) {}
    }

    return deletedCount;
  }

  /// Deletes a specific backup file.
  Future<bool> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Reads content of a local backup file.
  Future<String> readBackupContent(String filePath) async {
    final file = File(filePath);
    return file.readAsString();
  }
}

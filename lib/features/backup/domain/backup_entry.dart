/// Information about a local backup file stored on device (Task 11.6).
class BackupEntry {
  final String filePath;
  final String fileName;
  final int fileSizeBytes;
  final DateTime createdAt;
  final bool isAutoBackup;
  final int recordCount;

  const BackupEntry({
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.createdAt,
    required this.isAutoBackup,
    required this.recordCount,
  });

  String get formattedSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}

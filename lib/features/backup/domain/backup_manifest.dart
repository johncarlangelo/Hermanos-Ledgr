/// Manifest information embedded in full ledger backup JSON files (Task 11.1).
class BackupManifest {
  final DateTime exportDate;
  final String app;
  final int schemaVersion;
  final String appVersion;
  final int appBuildNumber;
  final int accountsCount;
  final int transactionsCount;
  final int categoriesCount;
  final int budgetsCount;
  final int goalsCount;
  final int debtsCount;
  final int recurringCount;
  final int chatMessagesCount;

  const BackupManifest({
    required this.exportDate,
    required this.app,
    this.schemaVersion = 1,
    required this.appVersion,
    required this.appBuildNumber,
    required this.accountsCount,
    required this.transactionsCount,
    required this.categoriesCount,
    required this.budgetsCount,
    required this.goalsCount,
    required this.debtsCount,
    required this.recurringCount,
    required this.chatMessagesCount,
  });

  Map<String, dynamic> toJson() => {
        'exportDate': exportDate.toIso8601String(),
        'app': app,
        'schemaVersion': schemaVersion,
        'appVersion': appVersion,
        'appBuildNumber': appBuildNumber,
        'accountsCount': accountsCount,
        'transactionsCount': transactionsCount,
        'categoriesCount': categoriesCount,
        'budgetsCount': budgetsCount,
        'goalsCount': goalsCount,
        'debtsCount': debtsCount,
        'recurringCount': recurringCount,
        'chatMessagesCount': chatMessagesCount,
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    return BackupManifest(
      exportDate: json['exportDate'] != null
          ? DateTime.tryParse(json['exportDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      app: json['app']?.toString() ?? 'Hermanos Ledgr',
      schemaVersion: json['schemaVersion'] is int ? json['schemaVersion'] : 1,
      appVersion: json['appVersion']?.toString() ?? 'unknown',
      appBuildNumber: json['appBuildNumber'] is int ? json['appBuildNumber'] : 0,
      accountsCount: json['accountsCount'] is int ? json['accountsCount'] : 0,
      transactionsCount:
          json['transactionsCount'] is int ? json['transactionsCount'] : 0,
      categoriesCount:
          json['categoriesCount'] is int ? json['categoriesCount'] : 0,
      budgetsCount: json['budgetsCount'] is int ? json['budgetsCount'] : 0,
      goalsCount: json['goalsCount'] is int ? json['goalsCount'] : 0,
      debtsCount: json['debtsCount'] is int ? json['debtsCount'] : 0,
      recurringCount:
          json['recurringCount'] is int ? json['recurringCount'] : 0,
      chatMessagesCount:
          json['chatMessagesCount'] is int ? json['chatMessagesCount'] : 0,
    );
  }
}

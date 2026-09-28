// TODO: Re-enable Isar imports when building for Android

class AppSettings {
  int id = 0;
  String currency = 'PHP';
  String theme = 'neumorphic-cream';
  DateTime? lastSyncedAt;
  String? deviceIdentifier;

  Map<String, dynamic> toJson() {
    return { 'currency': currency, 'theme': theme };
  }

  static AppSettings fromJson(Map<String, dynamic> json) {
    return AppSettings()
      ..currency = json['currency'] as String? ?? 'PHP'
      ..theme = json['theme'] as String? ?? 'neumorphic-cream';
  }
}

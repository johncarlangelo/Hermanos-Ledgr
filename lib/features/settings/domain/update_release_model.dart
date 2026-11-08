/// Data model representing a GitHub Release payload for OTA updates.
class UpdateReleaseModel {
  final String tagName;
  final String version;
  final String name;
  final String body;
  final String apkDownloadUrl;
  final String apkFileName;
  final int apkSizeBytes;
  final DateTime publishedAt;
  final String htmlUrl;

  const UpdateReleaseModel({
    required this.tagName,
    required this.version,
    required this.name,
    required this.body,
    required this.apkDownloadUrl,
    required this.apkFileName,
    required this.apkSizeBytes,
    required this.publishedAt,
    required this.htmlUrl,
  });

  /// Factory constructor to parse GitHub Releases API JSON.
  factory UpdateReleaseModel.fromJson(Map<String, dynamic> json) {
    final rawTag = (json['tag_name'] as String?) ?? 'v0.0.0';
    final cleanVersion = rawTag.startsWith('v') || rawTag.startsWith('V')
        ? rawTag.substring(1)
        : rawTag;

    // Search assets for the first .apk file
    final assets = (json['assets'] as List<dynamic>?) ?? [];
    String apkUrl = '';
    String apkName = 'hermanos-ledgr-$cleanVersion.apk';
    int apkSize = 0;

    for (final asset in assets) {
      if (asset is Map<String, dynamic>) {
        final name = (asset['name'] as String?) ?? '';
        final contentType = (asset['content_type'] as String?) ?? '';
        if (name.toLowerCase().endsWith('.apk') ||
            contentType == 'application/vnd.android.package-archive') {
          apkUrl = (asset['browser_download_url'] as String?) ?? '';
          apkName = name;
          apkSize = (asset['size'] as int?) ?? 0;
          break;
        }
      }
    }

    final publishedString = json['published_at'] as String?;
    final publishedDate = publishedString != null
        ? DateTime.tryParse(publishedString) ?? DateTime.now()
        : DateTime.now();

    return UpdateReleaseModel(
      tagName: rawTag,
      version: cleanVersion,
      name: (json['name'] as String?) ?? 'Hermanos Ledgr $rawTag',
      body: (json['body'] as String?) ?? 'No release notes provided.',
      apkDownloadUrl: apkUrl,
      apkFileName: apkName,
      apkSizeBytes: apkSize,
      publishedAt: publishedDate,
      htmlUrl: (json['html_url'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag_name': tagName,
      'version': version,
      'name': name,
      'body': body,
      'apk_download_url': apkDownloadUrl,
      'apk_file_name': apkFileName,
      'apk_size_bytes': apkSizeBytes,
      'published_at': publishedAt.toIso8601String(),
      'html_url': htmlUrl,
    };
  }

  UpdateReleaseModel copyWith({
    String? tagName,
    String? version,
    String? name,
    String? body,
    String? apkDownloadUrl,
    String? apkFileName,
    int? apkSizeBytes,
    DateTime? publishedAt,
    String? htmlUrl,
  }) {
    return UpdateReleaseModel(
      tagName: tagName ?? this.tagName,
      version: version ?? this.version,
      name: name ?? this.name,
      body: body ?? this.body,
      apkDownloadUrl: apkDownloadUrl ?? this.apkDownloadUrl,
      apkFileName: apkFileName ?? this.apkFileName,
      apkSizeBytes: apkSizeBytes ?? this.apkSizeBytes,
      publishedAt: publishedAt ?? this.publishedAt,
      htmlUrl: htmlUrl ?? this.htmlUrl,
    );
  }

  @override
  String toString() =>
      'UpdateReleaseModel(tag: $tagName, version: $version, apk: $apkFileName, size: $apkSizeBytes)';
}


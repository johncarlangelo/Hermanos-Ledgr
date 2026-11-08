/// Utility for comparing Semantic Version strings (e.g., 'v0.20.0' vs 'v0.19.0+49').
class SemVerComparator {
  SemVerComparator._();

  /// Clean a version tag by stripping leading 'v' / 'V' and prerelease identifiers.
  static String clean(String tag) {
    var cleaned = tag.trim();
    if (cleaned.startsWith('v') || cleaned.startsWith('V')) {
      cleaned = cleaned.substring(1);
    }
    // Remove prerelease tag if present (e.g. -alpha, -beta, -rc)
    if (cleaned.contains('-')) {
      cleaned = cleaned.split('-').first;
    }
    return cleaned;
  }

  /// Parses a version string into a list of numeric parts: [major, minor, patch, buildNumber].
  static List<int> parseParts(String version) {
    final cleaned = clean(version);

    // Check for build number suffix (+XX)
    int buildNumber = 0;
    String core = cleaned;
    if (cleaned.contains('+')) {
      final split = cleaned.split('+');
      core = split[0];
      if (split.length > 1) {
        buildNumber = int.tryParse(split[1]) ?? 0;
      }
    }

    final segments = core.split('.');
    final major = segments.isNotEmpty ? (int.tryParse(segments[0]) ?? 0) : 0;
    final minor = segments.length > 1 ? (int.tryParse(segments[1]) ?? 0) : 0;
    final patch = segments.length > 2 ? (int.tryParse(segments[2]) ?? 0) : 0;

    return [major, minor, patch, buildNumber];
  }

  /// Compares version string [a] with version string [b].
  /// Returns:
  /// - positive number if a > b
  /// - 0 if a == b
  /// - negative number if a < b
  static int compare(String a, String b) {
    final partsA = parseParts(a);
    final partsB = parseParts(b);

    // Compare Major, Minor, Patch
    for (int i = 0; i < 3; i++) {
      if (partsA[i] > partsB[i]) return 1;
      if (partsA[i] < partsB[i]) return -1;
    }

    // If Major, Minor, Patch are identical, compare build number if both provided
    if (partsA[3] > 0 || partsB[3] > 0) {
      if (partsA[3] > partsB[3]) return 1;
      if (partsA[3] < partsB[3]) return -1;
    }

    return 0;
  }

  /// Returns `true` if [remoteTag] is strictly newer than [localTag].
  static bool isNewer(String remoteTag, String localTag) {
    return compare(remoteTag, localTag) > 0;
  }
}


import 'dart:convert';

/// Represents a distinct user profile in Hermanos Ledgr (Task 12.5).
class ProfileModel {
  final String id;
  final String name;
  final String? avatarBase64;
  final bool isDefault;
  final int colorValue;
  final DateTime createdAt;

  const ProfileModel({
    required this.id,
    required this.name,
    this.avatarBase64,
    this.isDefault = false,
    this.colorValue = 0xFF00897B, // Stash Teal default
    required this.createdAt,
  });

  ProfileModel copyWith({
    String? id,
    String? name,
    String? avatarBase64,
    bool clearAvatar = false,
    bool? isDefault,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarBase64: clearAvatar ? null : (avatarBase64 ?? this.avatarBase64),
      isDefault: isDefault ?? this.isDefault,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarBase64': avatarBase64,
      'isDefault': isDefault,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarBase64: json['avatarBase64'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      colorValue: json['colorValue'] as int? ?? 0xFF00897B,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static List<ProfileModel> decodeList(String rawJson) {
    try {
      final List<dynamic> decoded = jsonDecode(rawJson);
      return decoded.map((e) => ProfileModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static String encodeList(List<ProfileModel> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }
}

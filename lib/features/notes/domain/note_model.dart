/// Represents a user financial quick note / scratchpad item (Task 12.7).
class NoteModel {
  final int id;
  final String profileId;
  final String content;
  final String? tag; // e.g. 'Expense', 'Reminder', 'Idea', 'General'
  final double? amount;
  final bool isDone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.id,
    this.profileId = 'default',
    required this.content,
    this.tag,
    this.amount,
    this.isDone = false,
    required this.createdAt,
    required this.updatedAt,
  });

  NoteModel copyWith({
    int? id,
    String? profileId,
    String? content,
    String? tag,
    bool clearTag = false,
    double? amount,
    bool clearAmount = false,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      content: content ?? this.content,
      tag: clearTag ? null : (tag ?? this.tag),
      amount: clearAmount ? null : (amount ?? this.amount),
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileId': profileId,
      'content': content,
      'tag': tag,
      'amount': amount,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as int,
      profileId: json['profileId'] as String? ?? 'default',
      content: json['content'] as String,
      tag: json['tag'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      isDone: json['isDone'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

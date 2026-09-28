// TODO: Re-enable Isar imports when building for Android
// This file is temporarily simplified for web UI testing.

enum TransactionType { expense, income }

class Transaction {
  int id = 0;
  late String txId;
  late TransactionType type;
  late double amount;
  late String title;
  String? note;
  late String category;
  late String channel;
  late DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'id': txId,
      'type': type == TransactionType.expense ? 'expense' : 'income',
      'amount': amount,
      'title': title,
      'note': note,
      'category': category,
      'channel': channel,
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }

  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction()
      ..txId = json['id'] as String
      ..type = json['type'] == 'income' ? TransactionType.income : TransactionType.expense
      ..amount = (json['amount'] as num).toDouble()
      ..title = json['title'] as String
      ..note = json['note'] as String?
      ..category = json['category'] as String
      ..channel = json['channel'] as String
      ..timestamp = DateTime.parse(json['timestamp'] as String);
  }
}

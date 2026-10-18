import 'package:drift/drift.dart';

/// Table storing local AI assistant chat messages and parsed transaction proposals (Task 9.16).
class ChatMessagesTable extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();
  BoolColumn get isUser => boolean()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get parsedTxJson => text().nullable()();
  BoolColumn get isConfirmed => boolean().withDefault(const Constant(false))();
  TextColumn get intent => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

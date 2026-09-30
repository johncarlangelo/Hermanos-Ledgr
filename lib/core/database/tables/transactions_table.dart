import 'package:drift/drift.dart';

class TransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // expense, income, transfer
  TextColumn get categoryId => text()();
  TextColumn get categoryName => text()();
  IntColumn get categoryIconCode => integer()();
  IntColumn get categoryColorValue => integer()();
  TextColumn get accountId => text()();
  TextColumn get accountName => text()();
  TextColumn get destinationAccountId => text().nullable()();
  TextColumn get destinationAccountName => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get receiptImagePath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

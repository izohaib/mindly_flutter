import 'package:drift/drift.dart';

class Links extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
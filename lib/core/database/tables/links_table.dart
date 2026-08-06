import 'package:drift/drift.dart';

class Links extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text()();
  TextColumn get title => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  RealColumn get imageWidth => real().nullable()();
  RealColumn get imageHeight => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
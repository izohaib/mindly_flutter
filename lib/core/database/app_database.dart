import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/links_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Links])
class AppDatabase extends _$AppDatabase {
  // AppDatabase() : super(_openConnection());

  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._internal();

  @override
  int get schemaVersion => 2;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'mindly_db');
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(links, links.title);
        await m.addColumn(links, links.imageUrl);
      }
    },
  );
}
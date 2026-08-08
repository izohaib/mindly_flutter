import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:mindly/core/database/tables/folder_links.dart';
import 'package:mindly/core/database/tables/folder_table.dart';
import 'tables/links_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Links, Folders, FolderLinks])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._internal();

  @override
  int get schemaVersion => 4;

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
      if (from < 3) {
        await m.addColumn(links, links.platform);
      }
      if (from < 4) {
        await m.createTable(folders);
        await m.createTable(folderLinks);
      }
    },
  );
}
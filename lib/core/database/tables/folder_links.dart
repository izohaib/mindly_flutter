import 'package:drift/drift.dart';
import 'folder_table.dart';
import 'links_table.dart';


class FolderLinks extends Table {
  IntColumn get folderId =>
      integer().references(Folders, #id, onDelete: KeyAction.cascade)();
  IntColumn get linkId =>
      integer().references(Links, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {folderId, linkId};
}
import 'package:drift/drift.dart';
import 'package:mindly/core/database/app_database.dart';

class FoldersRepository {
  FoldersRepository._internal();

  static final FoldersRepository instance = FoldersRepository._internal();

  final AppDatabase _db = AppDatabase.instance;

  Future<int> createFolder(String name) {
    return _db.into(_db.folders).insert(
      FoldersCompanion.insert(name: name),
    );
  }

  /// Add a link to a folder
  Future<void> addLinkToFolder(int linkId, int folderId) {
    return _db.into(_db.folderLinks).insert(
      FolderLinksCompanion.insert(linkId: linkId, folderId: folderId),
      mode: InsertMode.insertOrIgnore, // avoids duplicate error if already added
    );
  }

  /// Remove a link from a folder
  Future<void> removeLinkFromFolder(int linkId, int folderId) {
    return (_db.delete(_db.folderLinks)
      ..where((fl) => fl.linkId.equals(linkId) & fl.folderId.equals(folderId)))
        .go();
  }

  /// Get all links inside a specific folder
  Future<List<Link>> getLinksInFolder(int folderId) {
    final query = _db.select(_db.links).join([
      innerJoin(_db.folderLinks, _db.folderLinks.linkId.equalsExp(_db.links.id)),
    ])
      ..where(_db.folderLinks.folderId.equals(folderId));

    return query.map((row) => row.readTable(_db.links)).get();
  }

  /// Get all folders a specific link belongs to
  Future<List<Folder>> getFoldersForLink(int linkId) {
    final query = _db.select(_db.folders).join([
      innerJoin(_db.folderLinks, _db.folderLinks.folderId.equalsExp(_db.folders.id)),
    ])
      ..where(_db.folderLinks.linkId.equals(linkId));

    return query.map((row) => row.readTable(_db.folders)).get();
  }

  /// Watch all folders (for the folder list screen, live updates)
  Stream<List<Folder>> watchAllFolders() {
    return _db.select(_db.folders).watch();
  }

  /// Delete a folder entirely (junction rows auto-removed via cascade)
  Future<void> deleteFolder(int folderId) {
    return (_db.delete(_db.folders)..where((f) => f.id.equals(folderId))).go();
  }

  Stream<List<Link>> watchLinksInFolder(int folderId) {
    final query = _db.select(_db.links).join([
      innerJoin(_db.folderLinks, _db.folderLinks.linkId.equalsExp(_db.links.id)),
    ])
      ..where(_db.folderLinks.folderId.equals(folderId));

    return query
        .watch()
        .map((rows) => rows.map((row) => row.readTable(_db.links)).toList());
  }

}
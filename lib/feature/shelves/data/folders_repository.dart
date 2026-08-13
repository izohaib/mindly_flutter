import 'package:drift/drift.dart';
import 'package:mindly/core/database/app_database.dart';
import 'package:mindly/feature/shelves/data/folder_card_data.dart';

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

  /// Get up to [limit] most recently added link images for a folder
  Future<List<String>> getRecentLinkImages(int folderId, {int limit = 4}) async {
    final query = _db.select(_db.links).join([
      innerJoin(_db.folderLinks, _db.folderLinks.linkId.equalsExp(_db.links.id)),
    ])
      ..where(_db.folderLinks.folderId.equals(folderId))
      ..orderBy([OrderingTerm.desc(_db.folderLinks.addedAt)])
      ..limit(limit);

    final rows = await query.get();
    return rows
        .map((row) => row.readTable(_db.links).imageUrl)
        .whereType<String>()
        .toList();
  }

  /// Watch all folders with link count and up to [imageLimit] recent images, in one query
  Stream<List<FolderCardData>> watchAllFoldersWithDetails({int imageLimit = 4}) {
    final query = _db.select(_db.folders).join([
      leftOuterJoin(
        _db.folderLinks,
        _db.folderLinks.folderId.equalsExp(_db.folders.id),
      ),
      leftOuterJoin(
        _db.links,
        _db.links.id.equalsExp(_db.folderLinks.linkId),
      ),
    ]);

    return query.watch().map((rows) {
      final foldersById = <int, Folder>{};
      final countByFolder = <int, int>{};
      final imagesByFolder = <int, List<MapEntry<DateTime, String>>>{};

      for (final row in rows) {
        final folder = row.readTable(_db.folders);
        foldersById[folder.id] = folder;
        countByFolder.putIfAbsent(folder.id, () => 0);

        final link = row.readTableOrNull(_db.links);
        final folderLink = row.readTableOrNull(_db.folderLinks);

        if (link != null && folderLink != null) {
          countByFolder[folder.id] = countByFolder[folder.id]! + 1;

          if (link.imageUrl != null) {
            imagesByFolder
                .putIfAbsent(folder.id, () => [])
                .add(MapEntry(folderLink.addedAt, link.imageUrl!));
          }
        }
      }

      return foldersById.values.map((folder) {
        final images = imagesByFolder[folder.id] ?? [];
        images.sort((a, b) => b.key.compareTo(a.key));

        return FolderCardData(
          folder: folder,
          linkCount: countByFolder[folder.id] ?? 0,
          recentImages: images.take(imageLimit).map((e) => e.value).toList(),
        );
      }).toList();
    });
  }

}
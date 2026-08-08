import 'package:drift/drift.dart';
import 'package:mindly/core/database/app_database.dart';


class LinkRepository {
  static final LinkRepository instance = LinkRepository._internal(AppDatabase.instance);
  LinkRepository._internal(this._db);

  final AppDatabase _db;

  LinkRepository(this._db);


  Future<int> saveLink({required String platform, required String url}) {
    final rowId = _db.into(_db.links).insert(
      LinksCompanion.insert(
        url: url,
        platform: Value(platform),
      ),
    );
    return rowId;
  }


  /// Update metadata AFTER link is saved
  /// This can be async and doesn't block the user
  Future<void> updateMetadata({
    required int id,
    String? title,
    String? imageUrl,
    double? imageWidth,
    double? imageHeight,
  }) {
    return (_db.update(_db.links)..where((t) => t.id.equals(id))).write(
      LinksCompanion(
        title: Value(title),
        imageUrl: Value(imageUrl),
        imageWidth: Value(imageWidth),
        imageHeight: Value(imageHeight),
      ),
    );
  }

  Stream<List<Link>> watchAllLinks() {
    return _db.select(_db.links).watch();
  }

  /// Get links filtered by specific platform
  Future<List<Link>> getLinksByPlatform(String platform) {
    return (_db.select(_db.links)
      ..where((t) => t.platform.equals(platform))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<int> deleteLink(int id) {
    return (_db.delete(_db.links)..where((t) => t.id.equals(id))).go();
  }

  /// Get ALL links ordered by creation date (newest first)
  // Future<List<Link>> getAllLinks() {
  //   return (_db.select(_db.links)
  //     ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
  //       .get();
  // }



  /// Get ONLY platforms that have links in the database
  /// This is what you should use for filter chips - not all supported platforms
  Future<List<String>> getUsedPlatforms() async {
    final query = _db.selectOnly(_db.links, distinct: true)
      ..addColumns([_db.links.platform])
      ..orderBy([OrderingTerm.asc(_db.links.platform)]);

    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.links.platform) ?? 'other')
        .where((p) => p.isNotEmpty)
        .toList();
  }






  /// Get count of links per platform
  Future<Map<String, int>> getLinkCountByPlatform() async {
    final query = _db.selectOnly(_db.links)
      ..addColumns([_db.links.platform, _db.links.id.count()])
      ..groupBy([_db.links.platform]);

    final rows = await query.get();
    final result = <String, int>{};

    for (final row in rows) {
      final platform = row.read(_db.links.platform) ?? 'other';
      final count = row.read(_db.links.id.count()) ?? 0;
      result[platform] = count;
    }

    return result;
  }


}
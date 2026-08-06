import 'package:drift/drift.dart';
import 'package:mindly/core/database/app_database.dart';

class LinkRepository {
  static final LinkRepository instance = LinkRepository._internal(AppDatabase.instance);
  LinkRepository._internal(this._db);

  final AppDatabase _db;
  LinkRepository(this._db);

  Future<int> saveLink(String url) {
    final rowId = _db.into(_db.links).insert(
      LinksCompanion.insert(url: url),
    );
    return rowId;
  }

  Future<void> updateMetadata(
      {
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

  Future<List<Link>> getAllLinks() {
    return (_db.select(_db.links)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }
}
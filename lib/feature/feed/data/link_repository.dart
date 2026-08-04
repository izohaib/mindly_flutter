import 'package:drift/drift.dart';
import 'package:mindly/core/database/app_database.dart';

class LinkRepository {
  final AppDatabase _db;
  LinkRepository(this._db);

  Future<void> saveLink(String url) {
    return _db.into(_db.links).insert(
      LinksCompanion.insert(url: url),
    );
  }

  Future<List<Link>> getAllLinks() {
    return (_db.select(_db.links)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }
}
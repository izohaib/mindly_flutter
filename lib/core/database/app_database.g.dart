// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LinksTable extends Links with TableInfo<$LinksTable, Link> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, url, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'links';
  @override
  VerificationContext validateIntegrity(
    Insertable<Link> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Link map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Link(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LinksTable createAlias(String alias) {
    return $LinksTable(attachedDatabase, alias);
  }
}

class Link extends DataClass implements Insertable<Link> {
  final int id;
  final String url;
  final DateTime createdAt;
  const Link({required this.id, required this.url, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LinksCompanion toCompanion(bool nullToAbsent) {
    return LinksCompanion(
      id: Value(id),
      url: Value(url),
      createdAt: Value(createdAt),
    );
  }

  factory Link.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Link(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Link copyWith({int? id, String? url, DateTime? createdAt}) => Link(
    id: id ?? this.id,
    url: url ?? this.url,
    createdAt: createdAt ?? this.createdAt,
  );
  Link copyWithCompanion(LinksCompanion data) {
    return Link(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Link(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, url, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Link &&
          other.id == this.id &&
          other.url == this.url &&
          other.createdAt == this.createdAt);
}

class LinksCompanion extends UpdateCompanion<Link> {
  final Value<int> id;
  final Value<String> url;
  final Value<DateTime> createdAt;
  const LinksCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LinksCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    this.createdAt = const Value.absent(),
  }) : url = Value(url);
  static Insertable<Link> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LinksCompanion copyWith({
    Value<int>? id,
    Value<String>? url,
    Value<DateTime>? createdAt,
  }) {
    return LinksCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinksCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LinksTable links = $LinksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [links];
}

typedef $$LinksTableCreateCompanionBuilder =
    LinksCompanion Function({
      Value<int> id,
      required String url,
      Value<DateTime> createdAt,
    });
typedef $$LinksTableUpdateCompanionBuilder =
    LinksCompanion Function({
      Value<int> id,
      Value<String> url,
      Value<DateTime> createdAt,
    });

class $$LinksTableFilterComposer extends Composer<_$AppDatabase, $LinksTable> {
  $$LinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LinksTableOrderingComposer
    extends Composer<_$AppDatabase, $LinksTable> {
  $$LinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LinksTable> {
  $$LinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LinksTable,
          Link,
          $$LinksTableFilterComposer,
          $$LinksTableOrderingComposer,
          $$LinksTableAnnotationComposer,
          $$LinksTableCreateCompanionBuilder,
          $$LinksTableUpdateCompanionBuilder,
          (Link, BaseReferences<_$AppDatabase, $LinksTable, Link>),
          Link,
          PrefetchHooks Function()
        > {
  $$LinksTableTableManager(_$AppDatabase db, $LinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LinksCompanion(id: id, url: url, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String url,
                Value<DateTime> createdAt = const Value.absent(),
              }) =>
                  LinksCompanion.insert(id: id, url: url, createdAt: createdAt),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LinksTable,
      Link,
      $$LinksTableFilterComposer,
      $$LinksTableOrderingComposer,
      $$LinksTableAnnotationComposer,
      $$LinksTableCreateCompanionBuilder,
      $$LinksTableUpdateCompanionBuilder,
      (Link, BaseReferences<_$AppDatabase, $LinksTable, Link>),
      Link,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LinksTableTableManager get links =>
      $$LinksTableTableManager(_db, _db.links);
}

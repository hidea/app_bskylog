// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PostsTable extends Posts with TableInfo<$PostsTable, Post> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
      'uri', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _authorDidMeta =
      const VerificationMeta('authorDid');
  @override
  late final GeneratedColumn<String> authorDid = GeneratedColumn<String>(
      'author_did', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _indexedMeta =
      const VerificationMeta('indexed');
  @override
  late final GeneratedColumn<DateTime> indexed = GeneratedColumn<DateTime>(
      'indexed', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _replyDidMeta =
      const VerificationMeta('replyDid');
  @override
  late final GeneratedColumn<String> replyDid = GeneratedColumn<String>(
      'reply_did', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _havEmbedImagesMeta =
      const VerificationMeta('havEmbedImages');
  @override
  late final GeneratedColumn<bool> havEmbedImages = GeneratedColumn<bool>(
      'hav_embed_images', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("hav_embed_images" IN (0, 1))'));
  static const VerificationMeta _havEmbedExternalMeta =
      const VerificationMeta('havEmbedExternal');
  @override
  late final GeneratedColumn<bool> havEmbedExternal = GeneratedColumn<bool>(
      'hav_embed_external', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("hav_embed_external" IN (0, 1))'));
  static const VerificationMeta _havEmbedRecordMeta =
      const VerificationMeta('havEmbedRecord');
  @override
  late final GeneratedColumn<bool> havEmbedRecord = GeneratedColumn<bool>(
      'hav_embed_record', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("hav_embed_record" IN (0, 1))'));
  static const VerificationMeta _reasonRepostMeta =
      const VerificationMeta('reasonRepost');
  @override
  late final GeneratedColumn<bool> reasonRepost = GeneratedColumn<bool>(
      'reason_repost', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reason_repost" IN (0, 1))'));
  static const VerificationMeta _postMeta = const VerificationMeta('post');
  @override
  late final GeneratedColumn<String> post = GeneratedColumn<String>(
      'post', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uri,
        authorDid,
        indexed,
        replyDid,
        havEmbedImages,
        havEmbedExternal,
        havEmbedRecord,
        reasonRepost,
        post
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'posts';
  @override
  VerificationContext validateIntegrity(Insertable<Post> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uri')) {
      context.handle(
          _uriMeta, uri.isAcceptableOrUnknown(data['uri']!, _uriMeta));
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('author_did')) {
      context.handle(_authorDidMeta,
          authorDid.isAcceptableOrUnknown(data['author_did']!, _authorDidMeta));
    } else if (isInserting) {
      context.missing(_authorDidMeta);
    }
    if (data.containsKey('indexed')) {
      context.handle(_indexedMeta,
          indexed.isAcceptableOrUnknown(data['indexed']!, _indexedMeta));
    } else if (isInserting) {
      context.missing(_indexedMeta);
    }
    if (data.containsKey('reply_did')) {
      context.handle(_replyDidMeta,
          replyDid.isAcceptableOrUnknown(data['reply_did']!, _replyDidMeta));
    } else if (isInserting) {
      context.missing(_replyDidMeta);
    }
    if (data.containsKey('hav_embed_images')) {
      context.handle(
          _havEmbedImagesMeta,
          havEmbedImages.isAcceptableOrUnknown(
              data['hav_embed_images']!, _havEmbedImagesMeta));
    } else if (isInserting) {
      context.missing(_havEmbedImagesMeta);
    }
    if (data.containsKey('hav_embed_external')) {
      context.handle(
          _havEmbedExternalMeta,
          havEmbedExternal.isAcceptableOrUnknown(
              data['hav_embed_external']!, _havEmbedExternalMeta));
    } else if (isInserting) {
      context.missing(_havEmbedExternalMeta);
    }
    if (data.containsKey('hav_embed_record')) {
      context.handle(
          _havEmbedRecordMeta,
          havEmbedRecord.isAcceptableOrUnknown(
              data['hav_embed_record']!, _havEmbedRecordMeta));
    } else if (isInserting) {
      context.missing(_havEmbedRecordMeta);
    }
    if (data.containsKey('reason_repost')) {
      context.handle(
          _reasonRepostMeta,
          reasonRepost.isAcceptableOrUnknown(
              data['reason_repost']!, _reasonRepostMeta));
    } else if (isInserting) {
      context.missing(_reasonRepostMeta);
    }
    if (data.containsKey('post')) {
      context.handle(
          _postMeta, post.isAcceptableOrUnknown(data['post']!, _postMeta));
    } else if (isInserting) {
      context.missing(_postMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Post map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Post(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uri'])!,
      authorDid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author_did'])!,
      indexed: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}indexed'])!,
      replyDid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reply_did'])!,
      havEmbedImages: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}hav_embed_images'])!,
      havEmbedExternal: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}hav_embed_external'])!,
      havEmbedRecord: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}hav_embed_record'])!,
      reasonRepost: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}reason_repost'])!,
      post: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}post'])!,
    );
  }

  @override
  $PostsTable createAlias(String alias) {
    return $PostsTable(attachedDatabase, alias);
  }
}

class Post extends DataClass implements Insertable<Post> {
  final int id;
  final String uri;
  final String authorDid;
  final DateTime indexed;
  final String replyDid;
  final bool havEmbedImages;
  final bool havEmbedExternal;
  final bool havEmbedRecord;
  final bool reasonRepost;
  final String post;
  const Post(
      {required this.id,
      required this.uri,
      required this.authorDid,
      required this.indexed,
      required this.replyDid,
      required this.havEmbedImages,
      required this.havEmbedExternal,
      required this.havEmbedRecord,
      required this.reasonRepost,
      required this.post});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uri'] = Variable<String>(uri);
    map['author_did'] = Variable<String>(authorDid);
    map['indexed'] = Variable<DateTime>(indexed);
    map['reply_did'] = Variable<String>(replyDid);
    map['hav_embed_images'] = Variable<bool>(havEmbedImages);
    map['hav_embed_external'] = Variable<bool>(havEmbedExternal);
    map['hav_embed_record'] = Variable<bool>(havEmbedRecord);
    map['reason_repost'] = Variable<bool>(reasonRepost);
    map['post'] = Variable<String>(post);
    return map;
  }

  PostsCompanion toCompanion(bool nullToAbsent) {
    return PostsCompanion(
      id: Value(id),
      uri: Value(uri),
      authorDid: Value(authorDid),
      indexed: Value(indexed),
      replyDid: Value(replyDid),
      havEmbedImages: Value(havEmbedImages),
      havEmbedExternal: Value(havEmbedExternal),
      havEmbedRecord: Value(havEmbedRecord),
      reasonRepost: Value(reasonRepost),
      post: Value(post),
    );
  }

  factory Post.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Post(
      id: serializer.fromJson<int>(json['id']),
      uri: serializer.fromJson<String>(json['uri']),
      authorDid: serializer.fromJson<String>(json['authorDid']),
      indexed: serializer.fromJson<DateTime>(json['indexed']),
      replyDid: serializer.fromJson<String>(json['replyDid']),
      havEmbedImages: serializer.fromJson<bool>(json['havEmbedImages']),
      havEmbedExternal: serializer.fromJson<bool>(json['havEmbedExternal']),
      havEmbedRecord: serializer.fromJson<bool>(json['havEmbedRecord']),
      reasonRepost: serializer.fromJson<bool>(json['reasonRepost']),
      post: serializer.fromJson<String>(json['post']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uri': serializer.toJson<String>(uri),
      'authorDid': serializer.toJson<String>(authorDid),
      'indexed': serializer.toJson<DateTime>(indexed),
      'replyDid': serializer.toJson<String>(replyDid),
      'havEmbedImages': serializer.toJson<bool>(havEmbedImages),
      'havEmbedExternal': serializer.toJson<bool>(havEmbedExternal),
      'havEmbedRecord': serializer.toJson<bool>(havEmbedRecord),
      'reasonRepost': serializer.toJson<bool>(reasonRepost),
      'post': serializer.toJson<String>(post),
    };
  }

  Post copyWith(
          {int? id,
          String? uri,
          String? authorDid,
          DateTime? indexed,
          String? replyDid,
          bool? havEmbedImages,
          bool? havEmbedExternal,
          bool? havEmbedRecord,
          bool? reasonRepost,
          String? post}) =>
      Post(
        id: id ?? this.id,
        uri: uri ?? this.uri,
        authorDid: authorDid ?? this.authorDid,
        indexed: indexed ?? this.indexed,
        replyDid: replyDid ?? this.replyDid,
        havEmbedImages: havEmbedImages ?? this.havEmbedImages,
        havEmbedExternal: havEmbedExternal ?? this.havEmbedExternal,
        havEmbedRecord: havEmbedRecord ?? this.havEmbedRecord,
        reasonRepost: reasonRepost ?? this.reasonRepost,
        post: post ?? this.post,
      );
  Post copyWithCompanion(PostsCompanion data) {
    return Post(
      id: data.id.present ? data.id.value : this.id,
      uri: data.uri.present ? data.uri.value : this.uri,
      authorDid: data.authorDid.present ? data.authorDid.value : this.authorDid,
      indexed: data.indexed.present ? data.indexed.value : this.indexed,
      replyDid: data.replyDid.present ? data.replyDid.value : this.replyDid,
      havEmbedImages: data.havEmbedImages.present
          ? data.havEmbedImages.value
          : this.havEmbedImages,
      havEmbedExternal: data.havEmbedExternal.present
          ? data.havEmbedExternal.value
          : this.havEmbedExternal,
      havEmbedRecord: data.havEmbedRecord.present
          ? data.havEmbedRecord.value
          : this.havEmbedRecord,
      reasonRepost: data.reasonRepost.present
          ? data.reasonRepost.value
          : this.reasonRepost,
      post: data.post.present ? data.post.value : this.post,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Post(')
          ..write('id: $id, ')
          ..write('uri: $uri, ')
          ..write('authorDid: $authorDid, ')
          ..write('indexed: $indexed, ')
          ..write('replyDid: $replyDid, ')
          ..write('havEmbedImages: $havEmbedImages, ')
          ..write('havEmbedExternal: $havEmbedExternal, ')
          ..write('havEmbedRecord: $havEmbedRecord, ')
          ..write('reasonRepost: $reasonRepost, ')
          ..write('post: $post')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uri, authorDid, indexed, replyDid,
      havEmbedImages, havEmbedExternal, havEmbedRecord, reasonRepost, post);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Post &&
          other.id == this.id &&
          other.uri == this.uri &&
          other.authorDid == this.authorDid &&
          other.indexed == this.indexed &&
          other.replyDid == this.replyDid &&
          other.havEmbedImages == this.havEmbedImages &&
          other.havEmbedExternal == this.havEmbedExternal &&
          other.havEmbedRecord == this.havEmbedRecord &&
          other.reasonRepost == this.reasonRepost &&
          other.post == this.post);
}

class PostsCompanion extends UpdateCompanion<Post> {
  final Value<int> id;
  final Value<String> uri;
  final Value<String> authorDid;
  final Value<DateTime> indexed;
  final Value<String> replyDid;
  final Value<bool> havEmbedImages;
  final Value<bool> havEmbedExternal;
  final Value<bool> havEmbedRecord;
  final Value<bool> reasonRepost;
  final Value<String> post;
  const PostsCompanion({
    this.id = const Value.absent(),
    this.uri = const Value.absent(),
    this.authorDid = const Value.absent(),
    this.indexed = const Value.absent(),
    this.replyDid = const Value.absent(),
    this.havEmbedImages = const Value.absent(),
    this.havEmbedExternal = const Value.absent(),
    this.havEmbedRecord = const Value.absent(),
    this.reasonRepost = const Value.absent(),
    this.post = const Value.absent(),
  });
  PostsCompanion.insert({
    this.id = const Value.absent(),
    required String uri,
    required String authorDid,
    required DateTime indexed,
    required String replyDid,
    required bool havEmbedImages,
    required bool havEmbedExternal,
    required bool havEmbedRecord,
    required bool reasonRepost,
    required String post,
  })  : uri = Value(uri),
        authorDid = Value(authorDid),
        indexed = Value(indexed),
        replyDid = Value(replyDid),
        havEmbedImages = Value(havEmbedImages),
        havEmbedExternal = Value(havEmbedExternal),
        havEmbedRecord = Value(havEmbedRecord),
        reasonRepost = Value(reasonRepost),
        post = Value(post);
  static Insertable<Post> custom({
    Expression<int>? id,
    Expression<String>? uri,
    Expression<String>? authorDid,
    Expression<DateTime>? indexed,
    Expression<String>? replyDid,
    Expression<bool>? havEmbedImages,
    Expression<bool>? havEmbedExternal,
    Expression<bool>? havEmbedRecord,
    Expression<bool>? reasonRepost,
    Expression<String>? post,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uri != null) 'uri': uri,
      if (authorDid != null) 'author_did': authorDid,
      if (indexed != null) 'indexed': indexed,
      if (replyDid != null) 'reply_did': replyDid,
      if (havEmbedImages != null) 'hav_embed_images': havEmbedImages,
      if (havEmbedExternal != null) 'hav_embed_external': havEmbedExternal,
      if (havEmbedRecord != null) 'hav_embed_record': havEmbedRecord,
      if (reasonRepost != null) 'reason_repost': reasonRepost,
      if (post != null) 'post': post,
    });
  }

  PostsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uri,
      Value<String>? authorDid,
      Value<DateTime>? indexed,
      Value<String>? replyDid,
      Value<bool>? havEmbedImages,
      Value<bool>? havEmbedExternal,
      Value<bool>? havEmbedRecord,
      Value<bool>? reasonRepost,
      Value<String>? post}) {
    return PostsCompanion(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      authorDid: authorDid ?? this.authorDid,
      indexed: indexed ?? this.indexed,
      replyDid: replyDid ?? this.replyDid,
      havEmbedImages: havEmbedImages ?? this.havEmbedImages,
      havEmbedExternal: havEmbedExternal ?? this.havEmbedExternal,
      havEmbedRecord: havEmbedRecord ?? this.havEmbedRecord,
      reasonRepost: reasonRepost ?? this.reasonRepost,
      post: post ?? this.post,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (authorDid.present) {
      map['author_did'] = Variable<String>(authorDid.value);
    }
    if (indexed.present) {
      map['indexed'] = Variable<DateTime>(indexed.value);
    }
    if (replyDid.present) {
      map['reply_did'] = Variable<String>(replyDid.value);
    }
    if (havEmbedImages.present) {
      map['hav_embed_images'] = Variable<bool>(havEmbedImages.value);
    }
    if (havEmbedExternal.present) {
      map['hav_embed_external'] = Variable<bool>(havEmbedExternal.value);
    }
    if (havEmbedRecord.present) {
      map['hav_embed_record'] = Variable<bool>(havEmbedRecord.value);
    }
    if (reasonRepost.present) {
      map['reason_repost'] = Variable<bool>(reasonRepost.value);
    }
    if (post.present) {
      map['post'] = Variable<String>(post.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostsCompanion(')
          ..write('id: $id, ')
          ..write('uri: $uri, ')
          ..write('authorDid: $authorDid, ')
          ..write('indexed: $indexed, ')
          ..write('replyDid: $replyDid, ')
          ..write('havEmbedImages: $havEmbedImages, ')
          ..write('havEmbedExternal: $havEmbedExternal, ')
          ..write('havEmbedRecord: $havEmbedRecord, ')
          ..write('reasonRepost: $reasonRepost, ')
          ..write('post: $post')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PostsTable posts = $PostsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [posts];
}

typedef $$PostsTableCreateCompanionBuilder = PostsCompanion Function({
  Value<int> id,
  required String uri,
  required String authorDid,
  required DateTime indexed,
  required String replyDid,
  required bool havEmbedImages,
  required bool havEmbedExternal,
  required bool havEmbedRecord,
  required bool reasonRepost,
  required String post,
});
typedef $$PostsTableUpdateCompanionBuilder = PostsCompanion Function({
  Value<int> id,
  Value<String> uri,
  Value<String> authorDid,
  Value<DateTime> indexed,
  Value<String> replyDid,
  Value<bool> havEmbedImages,
  Value<bool> havEmbedExternal,
  Value<bool> havEmbedRecord,
  Value<bool> reasonRepost,
  Value<String> post,
});

class $$PostsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PostsTable,
    Post,
    $$PostsTableFilterComposer,
    $$PostsTableOrderingComposer,
    $$PostsTableCreateCompanionBuilder,
    $$PostsTableUpdateCompanionBuilder> {
  $$PostsTableTableManager(_$AppDatabase db, $PostsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PostsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PostsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uri = const Value.absent(),
            Value<String> authorDid = const Value.absent(),
            Value<DateTime> indexed = const Value.absent(),
            Value<String> replyDid = const Value.absent(),
            Value<bool> havEmbedImages = const Value.absent(),
            Value<bool> havEmbedExternal = const Value.absent(),
            Value<bool> havEmbedRecord = const Value.absent(),
            Value<bool> reasonRepost = const Value.absent(),
            Value<String> post = const Value.absent(),
          }) =>
              PostsCompanion(
            id: id,
            uri: uri,
            authorDid: authorDid,
            indexed: indexed,
            replyDid: replyDid,
            havEmbedImages: havEmbedImages,
            havEmbedExternal: havEmbedExternal,
            havEmbedRecord: havEmbedRecord,
            reasonRepost: reasonRepost,
            post: post,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uri,
            required String authorDid,
            required DateTime indexed,
            required String replyDid,
            required bool havEmbedImages,
            required bool havEmbedExternal,
            required bool havEmbedRecord,
            required bool reasonRepost,
            required String post,
          }) =>
              PostsCompanion.insert(
            id: id,
            uri: uri,
            authorDid: authorDid,
            indexed: indexed,
            replyDid: replyDid,
            havEmbedImages: havEmbedImages,
            havEmbedExternal: havEmbedExternal,
            havEmbedRecord: havEmbedRecord,
            reasonRepost: reasonRepost,
            post: post,
          ),
        ));
}

class $$PostsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PostsTable> {
  $$PostsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get uri => $state.composableBuilder(
      column: $state.table.uri,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get authorDid => $state.composableBuilder(
      column: $state.table.authorDid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get indexed => $state.composableBuilder(
      column: $state.table.indexed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get replyDid => $state.composableBuilder(
      column: $state.table.replyDid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get havEmbedImages => $state.composableBuilder(
      column: $state.table.havEmbedImages,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get havEmbedExternal => $state.composableBuilder(
      column: $state.table.havEmbedExternal,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get havEmbedRecord => $state.composableBuilder(
      column: $state.table.havEmbedRecord,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get reasonRepost => $state.composableBuilder(
      column: $state.table.reasonRepost,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get post => $state.composableBuilder(
      column: $state.table.post,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PostsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PostsTable> {
  $$PostsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get uri => $state.composableBuilder(
      column: $state.table.uri,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get authorDid => $state.composableBuilder(
      column: $state.table.authorDid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get indexed => $state.composableBuilder(
      column: $state.table.indexed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get replyDid => $state.composableBuilder(
      column: $state.table.replyDid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get havEmbedImages => $state.composableBuilder(
      column: $state.table.havEmbedImages,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get havEmbedExternal => $state.composableBuilder(
      column: $state.table.havEmbedExternal,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get havEmbedRecord => $state.composableBuilder(
      column: $state.table.havEmbedRecord,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get reasonRepost => $state.composableBuilder(
      column: $state.table.reasonRepost,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get post => $state.composableBuilder(
      column: $state.table.post,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db, _db.posts);
}

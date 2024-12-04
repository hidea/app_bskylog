// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Posts extends Table with TableInfo<Posts, PostsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Posts(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> feedAuthorDid = GeneratedColumn<String>(
      'feed_author_did', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: Constant(''));
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
      'uri', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  late final GeneratedColumn<String> authorDid = GeneratedColumn<String>(
      'author_did', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> indexed = GeneratedColumn<DateTime>(
      'indexed', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  late final GeneratedColumn<String> replyDid = GeneratedColumn<String>(
      'reply_did', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<bool> havEmbedImages = GeneratedColumn<bool>(
      'hav_embed_images', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("hav_embed_images" IN (0, 1))'));
  late final GeneratedColumn<bool> havEmbedExternal = GeneratedColumn<bool>(
      'hav_embed_external', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("hav_embed_external" IN (0, 1))'));
  late final GeneratedColumn<bool> havEmbedRecord = GeneratedColumn<bool>(
      'hav_embed_record', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("hav_embed_record" IN (0, 1))'));
  late final GeneratedColumn<bool> havEmbedRecordWithMedia =
      GeneratedColumn<bool>('hav_embed_record_with_media', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("hav_embed_record_with_media" IN (0, 1))'));
  late final GeneratedColumn<bool> havEmbedVideo = GeneratedColumn<bool>(
      'hav_embed_video', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("hav_embed_video" IN (0, 1))'));
  late final GeneratedColumn<bool> reasonRepost = GeneratedColumn<bool>(
      'reason_repost', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reason_repost" IN (0, 1))'));
  late final GeneratedColumn<String> post = GeneratedColumn<String>(
      'post', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        feedAuthorDid,
        uri,
        authorDid,
        indexed,
        replyDid,
        havEmbedImages,
        havEmbedExternal,
        havEmbedRecord,
        havEmbedRecordWithMedia,
        havEmbedVideo,
        reasonRepost,
        post
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'posts';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      feedAuthorDid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}feed_author_did'])!,
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
      havEmbedRecordWithMedia: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}hav_embed_record_with_media'])!,
      havEmbedVideo: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}hav_embed_video'])!,
      reasonRepost: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}reason_repost'])!,
      post: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}post'])!,
    );
  }

  @override
  Posts createAlias(String alias) {
    return Posts(attachedDatabase, alias);
  }
}

class PostsData extends DataClass implements Insertable<PostsData> {
  final int id;
  final String feedAuthorDid;
  final String uri;
  final String authorDid;
  final DateTime indexed;
  final String replyDid;
  final bool havEmbedImages;
  final bool havEmbedExternal;
  final bool havEmbedRecord;
  final bool havEmbedRecordWithMedia;
  final bool havEmbedVideo;
  final bool reasonRepost;
  final String post;
  const PostsData(
      {required this.id,
      required this.feedAuthorDid,
      required this.uri,
      required this.authorDid,
      required this.indexed,
      required this.replyDid,
      required this.havEmbedImages,
      required this.havEmbedExternal,
      required this.havEmbedRecord,
      required this.havEmbedRecordWithMedia,
      required this.havEmbedVideo,
      required this.reasonRepost,
      required this.post});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['feed_author_did'] = Variable<String>(feedAuthorDid);
    map['uri'] = Variable<String>(uri);
    map['author_did'] = Variable<String>(authorDid);
    map['indexed'] = Variable<DateTime>(indexed);
    map['reply_did'] = Variable<String>(replyDid);
    map['hav_embed_images'] = Variable<bool>(havEmbedImages);
    map['hav_embed_external'] = Variable<bool>(havEmbedExternal);
    map['hav_embed_record'] = Variable<bool>(havEmbedRecord);
    map['hav_embed_record_with_media'] =
        Variable<bool>(havEmbedRecordWithMedia);
    map['hav_embed_video'] = Variable<bool>(havEmbedVideo);
    map['reason_repost'] = Variable<bool>(reasonRepost);
    map['post'] = Variable<String>(post);
    return map;
  }

  PostsCompanion toCompanion(bool nullToAbsent) {
    return PostsCompanion(
      id: Value(id),
      feedAuthorDid: Value(feedAuthorDid),
      uri: Value(uri),
      authorDid: Value(authorDid),
      indexed: Value(indexed),
      replyDid: Value(replyDid),
      havEmbedImages: Value(havEmbedImages),
      havEmbedExternal: Value(havEmbedExternal),
      havEmbedRecord: Value(havEmbedRecord),
      havEmbedRecordWithMedia: Value(havEmbedRecordWithMedia),
      havEmbedVideo: Value(havEmbedVideo),
      reasonRepost: Value(reasonRepost),
      post: Value(post),
    );
  }

  factory PostsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostsData(
      id: serializer.fromJson<int>(json['id']),
      feedAuthorDid: serializer.fromJson<String>(json['feedAuthorDid']),
      uri: serializer.fromJson<String>(json['uri']),
      authorDid: serializer.fromJson<String>(json['authorDid']),
      indexed: serializer.fromJson<DateTime>(json['indexed']),
      replyDid: serializer.fromJson<String>(json['replyDid']),
      havEmbedImages: serializer.fromJson<bool>(json['havEmbedImages']),
      havEmbedExternal: serializer.fromJson<bool>(json['havEmbedExternal']),
      havEmbedRecord: serializer.fromJson<bool>(json['havEmbedRecord']),
      havEmbedRecordWithMedia:
          serializer.fromJson<bool>(json['havEmbedRecordWithMedia']),
      havEmbedVideo: serializer.fromJson<bool>(json['havEmbedVideo']),
      reasonRepost: serializer.fromJson<bool>(json['reasonRepost']),
      post: serializer.fromJson<String>(json['post']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'feedAuthorDid': serializer.toJson<String>(feedAuthorDid),
      'uri': serializer.toJson<String>(uri),
      'authorDid': serializer.toJson<String>(authorDid),
      'indexed': serializer.toJson<DateTime>(indexed),
      'replyDid': serializer.toJson<String>(replyDid),
      'havEmbedImages': serializer.toJson<bool>(havEmbedImages),
      'havEmbedExternal': serializer.toJson<bool>(havEmbedExternal),
      'havEmbedRecord': serializer.toJson<bool>(havEmbedRecord),
      'havEmbedRecordWithMedia':
          serializer.toJson<bool>(havEmbedRecordWithMedia),
      'havEmbedVideo': serializer.toJson<bool>(havEmbedVideo),
      'reasonRepost': serializer.toJson<bool>(reasonRepost),
      'post': serializer.toJson<String>(post),
    };
  }

  PostsData copyWith(
          {int? id,
          String? feedAuthorDid,
          String? uri,
          String? authorDid,
          DateTime? indexed,
          String? replyDid,
          bool? havEmbedImages,
          bool? havEmbedExternal,
          bool? havEmbedRecord,
          bool? havEmbedRecordWithMedia,
          bool? havEmbedVideo,
          bool? reasonRepost,
          String? post}) =>
      PostsData(
        id: id ?? this.id,
        feedAuthorDid: feedAuthorDid ?? this.feedAuthorDid,
        uri: uri ?? this.uri,
        authorDid: authorDid ?? this.authorDid,
        indexed: indexed ?? this.indexed,
        replyDid: replyDid ?? this.replyDid,
        havEmbedImages: havEmbedImages ?? this.havEmbedImages,
        havEmbedExternal: havEmbedExternal ?? this.havEmbedExternal,
        havEmbedRecord: havEmbedRecord ?? this.havEmbedRecord,
        havEmbedRecordWithMedia:
            havEmbedRecordWithMedia ?? this.havEmbedRecordWithMedia,
        havEmbedVideo: havEmbedVideo ?? this.havEmbedVideo,
        reasonRepost: reasonRepost ?? this.reasonRepost,
        post: post ?? this.post,
      );
  PostsData copyWithCompanion(PostsCompanion data) {
    return PostsData(
      id: data.id.present ? data.id.value : this.id,
      feedAuthorDid: data.feedAuthorDid.present
          ? data.feedAuthorDid.value
          : this.feedAuthorDid,
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
      havEmbedRecordWithMedia: data.havEmbedRecordWithMedia.present
          ? data.havEmbedRecordWithMedia.value
          : this.havEmbedRecordWithMedia,
      havEmbedVideo: data.havEmbedVideo.present
          ? data.havEmbedVideo.value
          : this.havEmbedVideo,
      reasonRepost: data.reasonRepost.present
          ? data.reasonRepost.value
          : this.reasonRepost,
      post: data.post.present ? data.post.value : this.post,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostsData(')
          ..write('id: $id, ')
          ..write('feedAuthorDid: $feedAuthorDid, ')
          ..write('uri: $uri, ')
          ..write('authorDid: $authorDid, ')
          ..write('indexed: $indexed, ')
          ..write('replyDid: $replyDid, ')
          ..write('havEmbedImages: $havEmbedImages, ')
          ..write('havEmbedExternal: $havEmbedExternal, ')
          ..write('havEmbedRecord: $havEmbedRecord, ')
          ..write('havEmbedRecordWithMedia: $havEmbedRecordWithMedia, ')
          ..write('havEmbedVideo: $havEmbedVideo, ')
          ..write('reasonRepost: $reasonRepost, ')
          ..write('post: $post')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      feedAuthorDid,
      uri,
      authorDid,
      indexed,
      replyDid,
      havEmbedImages,
      havEmbedExternal,
      havEmbedRecord,
      havEmbedRecordWithMedia,
      havEmbedVideo,
      reasonRepost,
      post);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostsData &&
          other.id == this.id &&
          other.feedAuthorDid == this.feedAuthorDid &&
          other.uri == this.uri &&
          other.authorDid == this.authorDid &&
          other.indexed == this.indexed &&
          other.replyDid == this.replyDid &&
          other.havEmbedImages == this.havEmbedImages &&
          other.havEmbedExternal == this.havEmbedExternal &&
          other.havEmbedRecord == this.havEmbedRecord &&
          other.havEmbedRecordWithMedia == this.havEmbedRecordWithMedia &&
          other.havEmbedVideo == this.havEmbedVideo &&
          other.reasonRepost == this.reasonRepost &&
          other.post == this.post);
}

class PostsCompanion extends UpdateCompanion<PostsData> {
  final Value<int> id;
  final Value<String> feedAuthorDid;
  final Value<String> uri;
  final Value<String> authorDid;
  final Value<DateTime> indexed;
  final Value<String> replyDid;
  final Value<bool> havEmbedImages;
  final Value<bool> havEmbedExternal;
  final Value<bool> havEmbedRecord;
  final Value<bool> havEmbedRecordWithMedia;
  final Value<bool> havEmbedVideo;
  final Value<bool> reasonRepost;
  final Value<String> post;
  const PostsCompanion({
    this.id = const Value.absent(),
    this.feedAuthorDid = const Value.absent(),
    this.uri = const Value.absent(),
    this.authorDid = const Value.absent(),
    this.indexed = const Value.absent(),
    this.replyDid = const Value.absent(),
    this.havEmbedImages = const Value.absent(),
    this.havEmbedExternal = const Value.absent(),
    this.havEmbedRecord = const Value.absent(),
    this.havEmbedRecordWithMedia = const Value.absent(),
    this.havEmbedVideo = const Value.absent(),
    this.reasonRepost = const Value.absent(),
    this.post = const Value.absent(),
  });
  PostsCompanion.insert({
    this.id = const Value.absent(),
    this.feedAuthorDid = const Value.absent(),
    required String uri,
    required String authorDid,
    required DateTime indexed,
    required String replyDid,
    required bool havEmbedImages,
    required bool havEmbedExternal,
    required bool havEmbedRecord,
    required bool havEmbedRecordWithMedia,
    required bool havEmbedVideo,
    required bool reasonRepost,
    required String post,
  })  : uri = Value(uri),
        authorDid = Value(authorDid),
        indexed = Value(indexed),
        replyDid = Value(replyDid),
        havEmbedImages = Value(havEmbedImages),
        havEmbedExternal = Value(havEmbedExternal),
        havEmbedRecord = Value(havEmbedRecord),
        havEmbedRecordWithMedia = Value(havEmbedRecordWithMedia),
        havEmbedVideo = Value(havEmbedVideo),
        reasonRepost = Value(reasonRepost),
        post = Value(post);
  static Insertable<PostsData> custom({
    Expression<int>? id,
    Expression<String>? feedAuthorDid,
    Expression<String>? uri,
    Expression<String>? authorDid,
    Expression<DateTime>? indexed,
    Expression<String>? replyDid,
    Expression<bool>? havEmbedImages,
    Expression<bool>? havEmbedExternal,
    Expression<bool>? havEmbedRecord,
    Expression<bool>? havEmbedRecordWithMedia,
    Expression<bool>? havEmbedVideo,
    Expression<bool>? reasonRepost,
    Expression<String>? post,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feedAuthorDid != null) 'feed_author_did': feedAuthorDid,
      if (uri != null) 'uri': uri,
      if (authorDid != null) 'author_did': authorDid,
      if (indexed != null) 'indexed': indexed,
      if (replyDid != null) 'reply_did': replyDid,
      if (havEmbedImages != null) 'hav_embed_images': havEmbedImages,
      if (havEmbedExternal != null) 'hav_embed_external': havEmbedExternal,
      if (havEmbedRecord != null) 'hav_embed_record': havEmbedRecord,
      if (havEmbedRecordWithMedia != null)
        'hav_embed_record_with_media': havEmbedRecordWithMedia,
      if (havEmbedVideo != null) 'hav_embed_video': havEmbedVideo,
      if (reasonRepost != null) 'reason_repost': reasonRepost,
      if (post != null) 'post': post,
    });
  }

  PostsCompanion copyWith(
      {Value<int>? id,
      Value<String>? feedAuthorDid,
      Value<String>? uri,
      Value<String>? authorDid,
      Value<DateTime>? indexed,
      Value<String>? replyDid,
      Value<bool>? havEmbedImages,
      Value<bool>? havEmbedExternal,
      Value<bool>? havEmbedRecord,
      Value<bool>? havEmbedRecordWithMedia,
      Value<bool>? havEmbedVideo,
      Value<bool>? reasonRepost,
      Value<String>? post}) {
    return PostsCompanion(
      id: id ?? this.id,
      feedAuthorDid: feedAuthorDid ?? this.feedAuthorDid,
      uri: uri ?? this.uri,
      authorDid: authorDid ?? this.authorDid,
      indexed: indexed ?? this.indexed,
      replyDid: replyDid ?? this.replyDid,
      havEmbedImages: havEmbedImages ?? this.havEmbedImages,
      havEmbedExternal: havEmbedExternal ?? this.havEmbedExternal,
      havEmbedRecord: havEmbedRecord ?? this.havEmbedRecord,
      havEmbedRecordWithMedia:
          havEmbedRecordWithMedia ?? this.havEmbedRecordWithMedia,
      havEmbedVideo: havEmbedVideo ?? this.havEmbedVideo,
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
    if (feedAuthorDid.present) {
      map['feed_author_did'] = Variable<String>(feedAuthorDid.value);
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
    if (havEmbedRecordWithMedia.present) {
      map['hav_embed_record_with_media'] =
          Variable<bool>(havEmbedRecordWithMedia.value);
    }
    if (havEmbedVideo.present) {
      map['hav_embed_video'] = Variable<bool>(havEmbedVideo.value);
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
          ..write('feedAuthorDid: $feedAuthorDid, ')
          ..write('uri: $uri, ')
          ..write('authorDid: $authorDid, ')
          ..write('indexed: $indexed, ')
          ..write('replyDid: $replyDid, ')
          ..write('havEmbedImages: $havEmbedImages, ')
          ..write('havEmbedExternal: $havEmbedExternal, ')
          ..write('havEmbedRecord: $havEmbedRecord, ')
          ..write('havEmbedRecordWithMedia: $havEmbedRecordWithMedia, ')
          ..write('havEmbedVideo: $havEmbedVideo, ')
          ..write('reasonRepost: $reasonRepost, ')
          ..write('post: $post')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV2 extends GeneratedDatabase {
  DatabaseAtV2(QueryExecutor e) : super(e);
  late final Posts posts = Posts(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [posts];
  @override
  int get schemaVersion => 2;
}

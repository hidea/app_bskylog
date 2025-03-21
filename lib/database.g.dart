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
  static const VerificationMeta _feedAuthorDidMeta =
      const VerificationMeta('feedAuthorDid');
  @override
  late final GeneratedColumn<String> feedAuthorDid = GeneratedColumn<String>(
      'feed_author_did', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: Constant(''));
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
  static const VerificationMeta _havEmbedRecordWithMediaMeta =
      const VerificationMeta('havEmbedRecordWithMedia');
  @override
  late final GeneratedColumn<bool> havEmbedRecordWithMedia =
      GeneratedColumn<bool>('hav_embed_record_with_media', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("hav_embed_record_with_media" IN (0, 1))'));
  static const VerificationMeta _havEmbedVideoMeta =
      const VerificationMeta('havEmbedVideo');
  @override
  late final GeneratedColumn<bool> havEmbedVideo = GeneratedColumn<bool>(
      'hav_embed_video', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("hav_embed_video" IN (0, 1))'));
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
  static const VerificationMeta _retrievedMeta =
      const VerificationMeta('retrieved');
  @override
  late final GeneratedColumn<DateTime> retrieved = GeneratedColumn<DateTime>(
      'retrieved', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: Constant(DateTime(2024, 1, 1)));
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
        post,
        retrieved
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
    if (data.containsKey('feed_author_did')) {
      context.handle(
          _feedAuthorDidMeta,
          feedAuthorDid.isAcceptableOrUnknown(
              data['feed_author_did']!, _feedAuthorDidMeta));
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
    if (data.containsKey('hav_embed_record_with_media')) {
      context.handle(
          _havEmbedRecordWithMediaMeta,
          havEmbedRecordWithMedia.isAcceptableOrUnknown(
              data['hav_embed_record_with_media']!,
              _havEmbedRecordWithMediaMeta));
    } else if (isInserting) {
      context.missing(_havEmbedRecordWithMediaMeta);
    }
    if (data.containsKey('hav_embed_video')) {
      context.handle(
          _havEmbedVideoMeta,
          havEmbedVideo.isAcceptableOrUnknown(
              data['hav_embed_video']!, _havEmbedVideoMeta));
    } else if (isInserting) {
      context.missing(_havEmbedVideoMeta);
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
    if (data.containsKey('retrieved')) {
      context.handle(_retrievedMeta,
          retrieved.isAcceptableOrUnknown(data['retrieved']!, _retrievedMeta));
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
      retrieved: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}retrieved'])!,
    );
  }

  @override
  $PostsTable createAlias(String alias) {
    return $PostsTable(attachedDatabase, alias);
  }
}

class Post extends DataClass implements Insertable<Post> {
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
  final DateTime retrieved;
  const Post(
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
      required this.post,
      required this.retrieved});
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
    map['retrieved'] = Variable<DateTime>(retrieved);
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
      retrieved: Value(retrieved),
    );
  }

  factory Post.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Post(
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
      retrieved: serializer.fromJson<DateTime>(json['retrieved']),
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
      'retrieved': serializer.toJson<DateTime>(retrieved),
    };
  }

  Post copyWith(
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
          String? post,
          DateTime? retrieved}) =>
      Post(
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
        retrieved: retrieved ?? this.retrieved,
      );
  Post copyWithCompanion(PostsCompanion data) {
    return Post(
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
      retrieved: data.retrieved.present ? data.retrieved.value : this.retrieved,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Post(')
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
          ..write('post: $post, ')
          ..write('retrieved: $retrieved')
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
      post,
      retrieved);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Post &&
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
          other.post == this.post &&
          other.retrieved == this.retrieved);
}

class PostsCompanion extends UpdateCompanion<Post> {
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
  final Value<DateTime> retrieved;
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
    this.retrieved = const Value.absent(),
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
    this.retrieved = const Value.absent(),
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
  static Insertable<Post> custom({
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
    Expression<DateTime>? retrieved,
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
      if (retrieved != null) 'retrieved': retrieved,
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
      Value<String>? post,
      Value<DateTime>? retrieved}) {
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
      retrieved: retrieved ?? this.retrieved,
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
    if (retrieved.present) {
      map['retrieved'] = Variable<DateTime>(retrieved.value);
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
          ..write('post: $post, ')
          ..write('retrieved: $retrieved')
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
  Value<String> feedAuthorDid,
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
  Value<DateTime> retrieved,
});
typedef $$PostsTableUpdateCompanionBuilder = PostsCompanion Function({
  Value<int> id,
  Value<String> feedAuthorDid,
  Value<String> uri,
  Value<String> authorDid,
  Value<DateTime> indexed,
  Value<String> replyDid,
  Value<bool> havEmbedImages,
  Value<bool> havEmbedExternal,
  Value<bool> havEmbedRecord,
  Value<bool> havEmbedRecordWithMedia,
  Value<bool> havEmbedVideo,
  Value<bool> reasonRepost,
  Value<String> post,
  Value<DateTime> retrieved,
});

class $$PostsTableFilterComposer extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feedAuthorDid => $composableBuilder(
      column: $table.feedAuthorDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uri => $composableBuilder(
      column: $table.uri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorDid => $composableBuilder(
      column: $table.authorDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get indexed => $composableBuilder(
      column: $table.indexed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyDid => $composableBuilder(
      column: $table.replyDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get havEmbedImages => $composableBuilder(
      column: $table.havEmbedImages,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get havEmbedExternal => $composableBuilder(
      column: $table.havEmbedExternal,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get havEmbedRecord => $composableBuilder(
      column: $table.havEmbedRecord,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get havEmbedRecordWithMedia => $composableBuilder(
      column: $table.havEmbedRecordWithMedia,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get havEmbedVideo => $composableBuilder(
      column: $table.havEmbedVideo, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get reasonRepost => $composableBuilder(
      column: $table.reasonRepost, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get post => $composableBuilder(
      column: $table.post, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get retrieved => $composableBuilder(
      column: $table.retrieved, builder: (column) => ColumnFilters(column));
}

class $$PostsTableOrderingComposer
    extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feedAuthorDid => $composableBuilder(
      column: $table.feedAuthorDid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uri => $composableBuilder(
      column: $table.uri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorDid => $composableBuilder(
      column: $table.authorDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get indexed => $composableBuilder(
      column: $table.indexed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyDid => $composableBuilder(
      column: $table.replyDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get havEmbedImages => $composableBuilder(
      column: $table.havEmbedImages,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get havEmbedExternal => $composableBuilder(
      column: $table.havEmbedExternal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get havEmbedRecord => $composableBuilder(
      column: $table.havEmbedRecord,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get havEmbedRecordWithMedia => $composableBuilder(
      column: $table.havEmbedRecordWithMedia,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get havEmbedVideo => $composableBuilder(
      column: $table.havEmbedVideo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get reasonRepost => $composableBuilder(
      column: $table.reasonRepost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get post => $composableBuilder(
      column: $table.post, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get retrieved => $composableBuilder(
      column: $table.retrieved, builder: (column) => ColumnOrderings(column));
}

class $$PostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get feedAuthorDid => $composableBuilder(
      column: $table.feedAuthorDid, builder: (column) => column);

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get authorDid =>
      $composableBuilder(column: $table.authorDid, builder: (column) => column);

  GeneratedColumn<DateTime> get indexed =>
      $composableBuilder(column: $table.indexed, builder: (column) => column);

  GeneratedColumn<String> get replyDid =>
      $composableBuilder(column: $table.replyDid, builder: (column) => column);

  GeneratedColumn<bool> get havEmbedImages => $composableBuilder(
      column: $table.havEmbedImages, builder: (column) => column);

  GeneratedColumn<bool> get havEmbedExternal => $composableBuilder(
      column: $table.havEmbedExternal, builder: (column) => column);

  GeneratedColumn<bool> get havEmbedRecord => $composableBuilder(
      column: $table.havEmbedRecord, builder: (column) => column);

  GeneratedColumn<bool> get havEmbedRecordWithMedia => $composableBuilder(
      column: $table.havEmbedRecordWithMedia, builder: (column) => column);

  GeneratedColumn<bool> get havEmbedVideo => $composableBuilder(
      column: $table.havEmbedVideo, builder: (column) => column);

  GeneratedColumn<bool> get reasonRepost => $composableBuilder(
      column: $table.reasonRepost, builder: (column) => column);

  GeneratedColumn<String> get post =>
      $composableBuilder(column: $table.post, builder: (column) => column);

  GeneratedColumn<DateTime> get retrieved =>
      $composableBuilder(column: $table.retrieved, builder: (column) => column);
}

class $$PostsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PostsTable,
    Post,
    $$PostsTableFilterComposer,
    $$PostsTableOrderingComposer,
    $$PostsTableAnnotationComposer,
    $$PostsTableCreateCompanionBuilder,
    $$PostsTableUpdateCompanionBuilder,
    (Post, BaseReferences<_$AppDatabase, $PostsTable, Post>),
    Post,
    PrefetchHooks Function()> {
  $$PostsTableTableManager(_$AppDatabase db, $PostsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> feedAuthorDid = const Value.absent(),
            Value<String> uri = const Value.absent(),
            Value<String> authorDid = const Value.absent(),
            Value<DateTime> indexed = const Value.absent(),
            Value<String> replyDid = const Value.absent(),
            Value<bool> havEmbedImages = const Value.absent(),
            Value<bool> havEmbedExternal = const Value.absent(),
            Value<bool> havEmbedRecord = const Value.absent(),
            Value<bool> havEmbedRecordWithMedia = const Value.absent(),
            Value<bool> havEmbedVideo = const Value.absent(),
            Value<bool> reasonRepost = const Value.absent(),
            Value<String> post = const Value.absent(),
            Value<DateTime> retrieved = const Value.absent(),
          }) =>
              PostsCompanion(
            id: id,
            feedAuthorDid: feedAuthorDid,
            uri: uri,
            authorDid: authorDid,
            indexed: indexed,
            replyDid: replyDid,
            havEmbedImages: havEmbedImages,
            havEmbedExternal: havEmbedExternal,
            havEmbedRecord: havEmbedRecord,
            havEmbedRecordWithMedia: havEmbedRecordWithMedia,
            havEmbedVideo: havEmbedVideo,
            reasonRepost: reasonRepost,
            post: post,
            retrieved: retrieved,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> feedAuthorDid = const Value.absent(),
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
            Value<DateTime> retrieved = const Value.absent(),
          }) =>
              PostsCompanion.insert(
            id: id,
            feedAuthorDid: feedAuthorDid,
            uri: uri,
            authorDid: authorDid,
            indexed: indexed,
            replyDid: replyDid,
            havEmbedImages: havEmbedImages,
            havEmbedExternal: havEmbedExternal,
            havEmbedRecord: havEmbedRecord,
            havEmbedRecordWithMedia: havEmbedRecordWithMedia,
            havEmbedVideo: havEmbedVideo,
            reasonRepost: reasonRepost,
            post: post,
            retrieved: retrieved,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PostsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PostsTable,
    Post,
    $$PostsTableFilterComposer,
    $$PostsTableOrderingComposer,
    $$PostsTableAnnotationComposer,
    $$PostsTableCreateCompanionBuilder,
    $$PostsTableUpdateCompanionBuilder,
    (Post, BaseReferences<_$AppDatabase, $PostsTable, Post>),
    Post,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db, _db.posts);
}

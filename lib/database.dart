import 'dart:convert';
import 'dart:io';

import 'package:bluesky/app_bsky_feed_defs.dart' as bsky_feed;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'database.steps.dart';
import 'model.dart';

part 'database.g.dart';

class Posts extends Table {
  IntColumn get id => integer().autoIncrement()(); // id integer
  TextColumn get feedAuthorDid =>
      text().withDefault(Constant(''))(); // did string
  TextColumn get uri => text().unique()(); // uri string
  TextColumn get authorDid => text()(); // author.did string
  DateTimeColumn get indexed => dateTime()(); // indexed DateTime
  TextColumn get replyDid => text()(); // reply
  BoolColumn get havEmbedImages => boolean()(); // images
  BoolColumn get havEmbedExternal => boolean()(); // linkcard
  BoolColumn get havEmbedRecord => boolean()(); // RQ
  BoolColumn get havEmbedRecordWithMedia => boolean()(); // RQ withMedia
  BoolColumn get havEmbedVideo => boolean()(); // video
  BoolColumn get reasonRepost => boolean()(); // repost
  TextColumn get post => text()(); // Post
  DateTimeColumn get retrieved => dateTime()
      .withDefault(Constant(DateTime(2024, 1, 1)))(); // last retrieved DateTime
}

@DriftDatabase(tables: [Posts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  Model? _model;
  setModel(Model model) {
    _model = model;
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: stepByStep(
          from2To3: (Migrator m, Schema3 schema) async {
            _model?.setMigrationState('Database migration');

            await m.addColumn(schema.posts, schema.posts.retrieved);

            _model?.setMigrationState(null);
          },
          from1To2: (Migrator m, Schema2 schema) async {
            _model?.setMigrationState('Database migration');

            await m.addColumn(schema.posts, schema.posts.feedAuthorDid);
            await transaction(
              () async {
                // fixed indexed value
                // feedAuthorDid: getFeedIndexed(feedView)
                // fixed feedAuthorDid value
                // indexed: getFeedAuthorDid(feedView)
                int cursor = 0;
                const int limit = 1000;

                while (true) {
                  _model?.setMigrationState('Database convert $cursor');

                  final postsList = await (select(posts)
                        ..where((tbl) => tbl.id.isBiggerThanValue(cursor))
                        ..orderBy([(tbl) => OrderingTerm(expression: tbl.id)])
                        ..limit(limit))
                      .get();
                  if (postsList.isEmpty) {
                    break;
                  }

                  for (final post in postsList) {
                    final feedView =
                        bsky_feed.FeedViewPost.fromJson(jsonDecode(post.post));
                    final newFeedAuthorDid = Model.getFeedAuthorDid(feedView);
                    final newIndexed = Model.getFeedIndexed(feedView);

                    await (update(posts)
                          ..where((tbl) => tbl.id.equals(post.id)))
                        .write(
                      PostsCompanion(
                        feedAuthorDid: Value(newFeedAuthorDid),
                        indexed: Value(newIndexed),
                      ),
                    );
                  }

                  cursor = postsList.last.id;
                }

                _model?.setMigrationState(null);
              },
            );
          },
        ),
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final docFolder = await getApplicationDocumentsDirectory();
      final file = File(path.join(docFolder.path, 'bskylog.sqlite'));
      if (kDebugMode) {
        print(file.path);
      }

      return NativeDatabase.createInBackground(file);
    });
  }
}

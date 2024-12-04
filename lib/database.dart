import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/internal/versioned_schema.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'database.steps.dart';

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
}

@DriftDatabase(tables: [Posts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: stepByStep(from1To2: (Migrator m, Schema2 schema) async {
          await m.addColumn(schema.posts, schema.posts.feedAuthorDid);
          await transaction(() async {
            // fixed indexed value
            // fixed feedAuthorDid value
          });
        }),
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

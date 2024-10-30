import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

part 'database.g.dart';

class Posts extends Table {
  IntColumn get id => integer().autoIncrement()(); // id integer
  TextColumn get uri => text().unique()(); // uri string
  TextColumn get authorDid => text()(); // author.did string
  DateTimeColumn get indexed => dateTime()(); // indexed DateTime
  TextColumn get replyDid => text()(); // reply
  BoolColumn get havEmbedImages => boolean()(); // images
  BoolColumn get havEmbedExternal => boolean()(); // linkcard
  BoolColumn get havEmbedRecord => boolean()(); // RQ
  BoolColumn get reasonRepost => boolean()(); // repost
  TextColumn get post => text()(); // Post
}

@DriftDatabase(tables: [Posts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final docFolder = await getApplicationDocumentsDirectory();
      final file = File(path.join(docFolder.path, 'db.sqlite'));
      if (kDebugMode) {
        print(file.path);
      }

      return NativeDatabase.createInBackground(file);
    });
  }
}

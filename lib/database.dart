import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

part 'database.g.dart';

class Posts extends Table {
  TextColumn get uri => text().unique()(); // uri string
  TextColumn get authorDid => text()(); // author.did string
  DateTimeColumn get indexed => dateTime()(); // indexed DateTime
  TextColumn get replyDid => text()(); // record.reply.did string // 返信
  BoolColumn get havEmbedImages =>
      boolean()(); // record.havEmbedImages boolean // 画像
  BoolColumn get havEmbedExternal =>
      boolean()(); // record.havEmbedExternal boolean // 外部リンク
  BoolColumn get havEmbedRecord =>
      boolean()(); // record.havEmbedRecord boolean // 引用RQ
  BoolColumn get reasonRepost => boolean()(); // reasonRepost boolean
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
      return NativeDatabase.createInBackground(file);
    });
  }
}

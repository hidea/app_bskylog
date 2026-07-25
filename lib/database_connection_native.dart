import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final docFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(docFolder.path, 'bskylog.sqlite'));
    if (kDebugMode) {
      print(file.path);
    }

    return NativeDatabase.createInBackground(file);
  });
}

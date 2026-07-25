import 'dart:io';

Future<void> writeFeedJson(String path, String json) {
  return File(path).writeAsString(json);
}

import 'package:bskylog/database.dart';
import 'package:bskylog/mcp_tools.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase database;
  late McpTools tools;

  setUp(() async {
    database = AppDatabase.connect(NativeDatabase.memory());
    tools = McpTools(database);

    await database.batch((batch) {
      batch.insertAll(database.posts, [
        _post('first', DateTime.utc(2026, 1, 10), 'alpha 123'),
        _post('second', DateTime.utc(2026, 2, 10), 'alpha xyz'),
        _post('third', DateTime.utc(2026, 3, 10), 'beta 123'),
      ]);
    });
  });

  tearDown(() => database.close());

  test('combines regex pattern and date range', () async {
    final results = await tools.searchPostsFiltered(
      pattern: r'alpha\s+\d+',
      start: DateTime.utc(2026, 1, 1),
      end: DateTime.utc(2026, 2, 28, 23, 59, 59),
      limit: 10,
    );

    expect(results.map((result) => result['uri']), ['first']);
  });

  test('supports a one-sided date range with a pattern', () async {
    final results = await tools.searchPostsFiltered(
      pattern: r'123',
      start: DateTime.utc(2026, 2, 1),
      limit: 10,
    );

    expect(results.map((result) => result['uri']), ['third']);
  });

  test('combines keyword and date range', () async {
    final results = await tools.searchPostsFiltered(
      keyword: 'alpha',
      start: DateTime.utc(2026, 2, 1),
      end: DateTime.utc(2026, 3, 31, 23, 59, 59),
      limit: 10,
    );

    expect(results.map((result) => result['uri']), ['second']);
  });
}

PostsCompanion _post(String uri, DateTime indexed, String post) {
  return PostsCompanion.insert(
    uri: uri,
    authorDid: 'did:example:author',
    indexed: indexed,
    replyDid: '',
    havEmbedImages: false,
    havEmbedExternal: false,
    havEmbedRecord: false,
    havEmbedRecordWithMedia: false,
    havEmbedVideo: false,
    reasonRepost: false,
    post: post,
  );
}

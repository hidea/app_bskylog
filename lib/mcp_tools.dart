import 'database.dart';
import 'package:drift/drift.dart';

class McpTools {
  final AppDatabase database;
  McpTools(this.database);

  Future<List<Map<String, dynamic>>> getRecentPosts(int limit) async {
    final posts = await (database.select(database.posts)
          ..orderBy([
            (t) => OrderingTerm(expression: t.indexed, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();
    return posts
        .map((row) => {
              'post': row.post,
              'indexed': row.indexed.toIso8601String(),
              'uri': row.uri,
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> searchPosts(
      String keyword, int limit) async {
    final posts = await (database.select(database.posts)
          ..where((t) => t.post.like('%$keyword%'))
          ..orderBy([
            (t) => OrderingTerm(expression: t.indexed, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();
    return posts
        .map((row) => {
              'post': row.post,
              'indexed': row.indexed.toIso8601String(),
              'uri': row.uri,
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getUserActivity(
      String userId, int limit) async {
    final posts = await (database.select(database.posts)
          ..where((t) => t.authorDid.equals(userId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.indexed, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();
    return posts
        .map((row) => {
              'post': row.post,
              'indexed': row.indexed.toIso8601String(),
              'uri': row.uri,
            })
        .toList();
  }

  /// Resolves a handle (e.g. "@hidea.bsky.social" or "hidea.bsky.social") to a DID
  /// by searching the local database. Returns null if not found.
  Future<String?> resolveHandleToDid(String handle) async {
    // Remove '@' if present
    final cleanHandle = handle.startsWith('@') ? handle.substring(1) : handle;

    // Search for a post that contains this handle in the JSON content.
    // We look for '"handle":"handle.name"' pattern in the post JSON.
    final match = await (database.select(database.posts)
          ..where((t) => t.post.like('%"handle":"$cleanHandle"%'))
          ..limit(1))
        .getSingleOrNull();

    if (match != null) {
      return match.authorDid;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> searchPostsByDateRange(
      String keyword, DateTime start, DateTime end, int limit) async {
    final query = database.select(database.posts)
      ..where((t) => t.post.like('%$keyword%'))
      ..where((t) => t.indexed.isBetweenValues(start, end))
      ..orderBy([
        (t) => OrderingTerm(expression: t.indexed, mode: OrderingMode.desc)
      ])
      ..limit(limit);

    final results = await query.get();
    return results
        .map((row) => {
              'post': row.post,
              'indexed': row.indexed.toIso8601String(),
              'uri': row.uri,
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> searchPostsByPattern(
      String pattern, int limit) async {
    final query = database.select(database.posts)
      ..where((t) => t.post.regexp(pattern, unicode: true))
      ..orderBy([
        (t) => OrderingTerm(expression: t.indexed, mode: OrderingMode.desc)
      ])
      ..limit(limit);

    final results = await query.get();
    return results
        .map((row) => {
              'post': row.post,
              'indexed': row.indexed.toIso8601String(),
              'uri': row.uri,
            })
        .toList();
  }

  Future<Map<String, dynamic>> getMonthlyActivitySummary(int year) async {
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year, 12, 31, 23, 59, 59);

    final posts = await (database.select(database.posts)
          ..where((t) => t.indexed.isBetweenValues(startOfYear, endOfYear)))
        .get();

    final Map<int, int> monthlyCount = {};
    final Map<int, Map<String, int>> monthlyTags = {};

    for (var row in posts) {
      final month = row.indexed.month;
      monthlyCount[month] = (monthlyCount[month] ?? 0) + 1;

      // Simple hashtag extraction (words starting with #)
      // Ideally JSON should be parsed, but simplified extraction used for performance
      final text = row.post; // Use regex to find text within the JSON content
      final regExp = RegExp(r'#([^\s#]+)');
      final matches = regExp.allMatches(text);
      for (var match in matches) {
        final tag = match.group(1)!;
        monthlyTags.putIfAbsent(month, () => {});
        monthlyTags[month]![tag] = (monthlyTags[month]![tag] ?? 0) + 1;
      }
    }

    final summary = <String, dynamic>{};
    for (int m = 1; m <= 12; m++) {
      if (monthlyCount.containsKey(m)) {
        final tags = monthlyTags[m]?.entries.toList() ?? [];
        tags.sort((a, b) => b.value.compareTo(a.value));
        summary[m.toString()] = {
          'post_count': monthlyCount[m],
          'top_tags': tags.take(5).map((e) => e.key).toList(),
        };
      }
    }

    return {
      'year': year,
      'monthly_summary': summary,
    };
  }
}

enum VisibleMode { show, hide, only, disable }

enum VisibleType { reply, repost, quote, linkcard, image, video }

enum SortOrder { asc, desc }

class Define {
  static const title = 'bskylog';

  static const serviceBskySocial = 'bsky.social';
  static const bskyUrl = 'https://bsky.app';
  static const appPasswordUrl = '$bskyUrl/settings/app-passwords';
}

class FeedNode {
  final int count;
  final DateTime date;

  FeedNode({required this.count, required this.date});
}

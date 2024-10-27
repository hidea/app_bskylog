import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bluesky/bluesky.dart' as bluesky;

import 'define.dart';
import 'utils.dart';

class FeedCard extends StatefulWidget {
  const FeedCard(this.feed, {super.key});

  final bluesky.FeedView feed;

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  @override
  Widget build(BuildContext context) {
    final feed = widget.feed;
    final author = feed.post.author;
    final displayName =
        author.displayName != null && author.displayName!.isNotEmpty
            ? author.displayName!
            : author.handle;
    final avator = author.avatar != null ? NetworkImage(author.avatar!) : null;
    final postUrl =
        '${Define.bskyUrl}/profile/${author.handle}/post/${feed.post.uri.rkey}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          titleAlignment: ListTileTitleAlignment.top,
          leading: CircleAvatar(
            radius: 20.0,
            backgroundImage: avator,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(displayName),
            ],
          ),
          subtitle: Text(widget.feed.post.record.text),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(width: 68),
            TextButton(
              child: Text(
                  DateFormat('H:mm yyyy-MM-dd').format(feed.post.indexedAt)),
              onPressed: () => launchUrlPlus(postUrl),
            ),
          ],
        ),
      ],
    );
  }
}

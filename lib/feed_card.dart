import 'package:bskylog/embed_external.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bluesky/bluesky.dart' as bluesky;

import 'define.dart';
import 'embed_images.dart';
import 'utils.dart';

class FeedCard extends StatefulWidget {
  const FeedCard(this.feed, this.feedView, {super.key});

  final dynamic feed;
  final bluesky.FeedView feedView;

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  @override
  Widget build(BuildContext context) {
    final feed = widget.feed;
    final feedView = widget.feedView;
    final author = feedView.post.author;
    final displayName =
        author.displayName != null && author.displayName!.isNotEmpty
            ? author.displayName!
            : author.handle;
    final avator = author.avatar != null ? NetworkImage(author.avatar!) : null;
    final postUrl =
        '${Define.bskyUrl}/profile/${author.handle}/post/${feedView.post.uri.rkey}';

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (feed.reasonRepost)
          const Row(
            children: [
              SizedBox(width: 50),
              Icon(Icons.repeat, size: 16, color: Colors.blueGrey),
              Text('repost', style: TextStyle(color: Colors.blueGrey)),
            ],
          ),
        SelectionArea(
          child: ListTile(
            titleAlignment: ListTileTitleAlignment.top,
            leading: CircleAvatar(
              radius: 20.0,
              backgroundImage: avator,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(displayName),
                const SizedBox(width: 4),
                Text(
                  '@${author.handle}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            subtitle: Text(feedView.post.record.text),
            // TODO: record.facets
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 64),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (feedView.post.embed != null &&
                    feedView.post.embed is bluesky.UEmbedViewImages)
                  EmbedImagesWidget(
                      (feedView.post.embed as bluesky.UEmbedViewImages).data),
                if (feedView.post.embed != null &&
                    feedView.post.embed is bluesky.UEmbedViewExternal)
                  EmbedExternalWidget(
                      (feedView.post.embed as bluesky.UEmbedViewExternal).data),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(DateFormat('H:mm yyyy-MM-dd')
                          .format(feedView.post.indexedAt.toLocal())),
                      onPressed: () => launchUrlPlus(postUrl),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

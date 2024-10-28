import 'package:bskylog/embed_external.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bluesky/bluesky.dart' as bluesky;

import 'define.dart';
import 'embed_images.dart';
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
      mainAxisAlignment: MainAxisAlignment.start,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SelectableText(displayName),
              const SizedBox(width: 4),
              SelectableText(
                '@${author.handle}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          subtitle: SelectableText(widget.feed.post.record.text),
          // TODO: record.facets
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 64),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (feed.post.embed != null &&
                    feed.post.embed is bluesky.UEmbedViewImages)
                  EmbedImagesWidget(
                      (feed.post.embed as bluesky.UEmbedViewImages).data),
                if (feed.post.embed != null &&
                    feed.post.embed is bluesky.UEmbedViewExternal)
                  EmbedExternalWidget(
                      (feed.post.embed as bluesky.UEmbedViewExternal).data),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(DateFormat('H:mm yyyy-MM-dd')
                          .format(feed.post.indexedAt)),
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

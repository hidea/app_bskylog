import 'dart:convert';

import 'package:bskylog/embed_external.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bluesky/bluesky.dart' as bluesky;
import 'package:provider/provider.dart';

import 'define.dart';
import 'embed_images.dart';
import 'embed_video.dart';
import 'model.dart';
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (feed.reasonRepost) _buildRepost(),
        if (feed.replyDid.isNotEmpty) _buildReply(),
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
            subtitle: _buildRecordText(),
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
                if (feedView.post.embed != null &&
                    feedView.post.embed is bluesky.UEmbedViewVideo)
                  EmbedVideoWidget(
                      (feedView.post.embed as bluesky.UEmbedViewVideo).data),
                _buildFooter(),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordText() {
    final feedView = widget.feedView;
    final record = feedView.post.record;
    final utf8text = utf8.encode(record.text);

    List<InlineSpan> spans = [];
    int byteCurrent = 0;

    if (record.facets != null && record.facets!.isNotEmpty) {
      final facets = record.facets!;
      //facets.sort((a, b) => a.index.byteStart - b.index.byteStart);

      for (final facet in facets) {
        final intro = utf8text.sublist(byteCurrent, facet.index.byteStart);
        spans.add(TextSpan(text: utf8.decode(intro)));

        final body =
            utf8text.sublist(facet.index.byteStart, facet.index.byteEnd);
        final bodyText = utf8.decode(body);

        for (final feature in facet.features) {
          if (feature is bluesky.UFacetFeatureMention) {
            spans.add(_TooltipSpan(
                child: InkWell(
                  child: Text(bodyText, style: TextStyle(color: Colors.blue)),
                  onTap: () => _tapMention(feature.data),
                ),
                tooltip: 'Search mention'));
          } else if (feature is bluesky.UFacetFeatureLink) {
            spans.add(_TooltipSpan(
                child: InkWell(
                  child: Text(bodyText, style: TextStyle(color: Colors.blue)),
                  onTap: () => _tapLink(feature.data),
                ),
                tooltip: 'View link'));
          } else if (feature is bluesky.UFacetFeatureTag) {
            spans.add(_TooltipSpan(
                child: InkWell(
                  child: Text(bodyText, style: TextStyle(color: Colors.blue)),
                  onTap: () => _tapTag(feature.data),
                ),
                tooltip: 'Search hashtag'));
          } else {
            spans.add(TextSpan(text: bodyText));
          }
          break;
        }

        byteCurrent = facet.index.byteEnd;
      }
    }
    final left = utf8text.sublist(byteCurrent);
    spans.add(TextSpan(text: utf8.decode(left)));

    return Text.rich(TextSpan(children: spans));
  }

  void _tapMention(bluesky.FacetMention feature) {
    context.read<Model>().setSearchKeyword(feature.did);
  }

  void _tapLink(bluesky.FacetLink feature) {
    launchUrlPlus(feature.uri);
  }

  void _tapTag(bluesky.FacetTag feature) {
    context.read<Model>().setSearchKeyword('#${feature.tag}');
  }

  Widget _buildRepost() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: const Row(
        children: [
          SizedBox(width: 50),
          Icon(Icons.repeat, size: 16, color: Colors.blueGrey),
          SizedBox(width: 8),
          Text('repost', style: TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _buildReply() {
    final feedView = widget.feedView;
    final post = (feedView.reply!.parent as bluesky.UReplyPostRecord).data;
    final author = post.author;
    final displayName =
        author.displayName != null && author.displayName!.isNotEmpty
            ? author.displayName!
            : author.handle;
    final postUrl =
        '${Define.bskyUrl}/profile/${author.handle}/post/${post.uri.rkey}';

    return Row(
      children: [
        SizedBox(width: 36),
        TextButton(
          onPressed: () => launchUrlPlus(postUrl),
          child: Row(
            children: [
              Icon(Icons.reply, size: 16, color: Colors.blueGrey),
              SizedBox(width: 4),
              Text('reply to ', style: TextStyle(color: Colors.blueGrey)),
              Text(displayName, style: TextStyle(color: Colors.blueGrey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final feedView = widget.feedView;
    final author = feedView.post.author;
    final postUrl =
        '${Define.bskyUrl}/profile/${author.handle}/post/${feedView.post.uri.rkey}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Tooltip(
          message: 'View on Bluesky',
          waitDuration: Duration(milliseconds: 500),
          child: TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(DateFormat('H:mm yyyy-MM-dd')
                .format(feedView.post.indexedAt.toLocal())),
            onPressed: () => launchUrlPlus(postUrl),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 18,
          height: 18,
          child: IconButton(
            icon: const Icon(Icons.today),
            iconSize: 18,
            padding: EdgeInsets.zero,
            tooltip: 'Search this day',
            onPressed: () {
              final day = feedView.post.indexedAt.toLocal();
              context.read<Model>().setSearchDay(day.year, day.month, day.day);
            },
          ),
        ),
      ],
    );
  }
}

class _TooltipSpan extends WidgetSpan {
  _TooltipSpan({required String tooltip, required Widget child})
      : super(child: Tooltip(message: tooltip, child: child));
}

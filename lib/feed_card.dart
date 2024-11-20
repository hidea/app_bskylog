import 'dart:convert';
import 'dart:io';

import 'package:bskylog/embed_external.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bluesky/bluesky.dart' as bluesky;
import 'package:provider/provider.dart';

import 'define.dart';
import 'embed_record.dart';
import 'embed_images.dart';
import 'embed_record_with_media.dart';
import 'embed_video.dart';
import 'model.dart';
import 'tooltip_span.dart';
import 'utils.dart';

final isDesktop = (Platform.isMacOS || Platform.isLinux || Platform.isWindows);

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
    final post = widget.feedView.post;
    final author = post.author;
    final displayName =
        author.displayName != null && author.displayName!.isNotEmpty
            ? author.displayName!
            : author.handle;
    final avator = author.avatar != null ? NetworkImage(author.avatar!) : null;

    final embedWidth =
        isDesktop ? 430.0 : MediaQuery.of(context).size.width - 96.0;

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (feed.reasonRepost) _buildRepost(),
          if (feed.replyDid.isNotEmpty) _buildReply(widget.feedView),
          SelectionArea(
            child: ListTile(
              titleAlignment: ListTileTitleAlignment.top,
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: avator,
              ),
              title: RichText(
                text: TextSpan(
                    text: displayName,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    children: [
                      WidgetSpan(child: SizedBox(width: 4)),
                      TextSpan(
                        text: '@${author.handle}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ]),
              ),
              subtitle: _buildRecordText(post.record),
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
                  if (post.embed != null)
                    switch (post.embed!) {
                      (bluesky.UEmbedViewRecord record) => EmbedRecordWidget(
                          record.data,
                          width: embedWidth,
                          height: embedWidth,
                        ),
                      (bluesky.UEmbedViewRecordWithMedia recordWithMedia) =>
                        EmbedRecordWithMediaWidget(
                          recordWithMedia.data,
                          width: embedWidth,
                          height: embedWidth,
                        ),
                      (bluesky.UEmbedViewImages images) => EmbedImagesWidget(
                          images.data,
                          width: embedWidth,
                          height: embedWidth / 2,
                        ),
                      (bluesky.UEmbedViewExternal external) =>
                        EmbedExternalWidget(
                          external.data,
                          width: embedWidth,
                          height: embedWidth / 2,
                        ),
                      (bluesky.UEmbedViewVideo video) => EmbedVideoWidget(
                          video.data,
                          width: embedWidth,
                          height: embedWidth / 2,
                        ),
                      bluesky.EmbedView() => const Text('unsupported embed'),
                    },
                  _buildFooter(post),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordText(bluesky.PostRecord record) {
    final utf8text = utf8.encode(record.text);

    List<InlineSpan> spans = [];
    int byteCurrent = 0;

    if (record.facets != null && record.facets!.isNotEmpty) {
      final facets = record.facets!;
      //facets.sort((a, b) => a.index.byteStart - b.index.byteStart);

      for (final facet in facets) {
        final intro = utf8text.sublist(byteCurrent, facet.index.byteStart);
        spans.add(TextSpan(
            text: utf8.decode(intro), style: TextStyle(color: Colors.black)));

        final body =
            utf8text.sublist(facet.index.byteStart, facet.index.byteEnd);
        final bodyText = utf8.decode(body);

        for (final feature in facet.features) {
          feature.when(
            mention: (mention) {
              spans.add(TooltipSpan(
                  child: InkWell(
                    child: Text(bodyText, style: TextStyle(color: Colors.blue)),
                    onTap: () => _tapMention(mention),
                  ),
                  tooltip: 'Search mention'));
            },
            link: (link) {
              spans.add(TooltipSpan(
                  child: InkWell(
                    child: Text(bodyText, style: TextStyle(color: Colors.blue)),
                    onTap: () => _tapLink(link),
                  ),
                  tooltip: 'View link'));
            },
            tag: (tag) {
              spans.add(TooltipSpan(
                  child: InkWell(
                    child: Text(bodyText, style: TextStyle(color: Colors.blue)),
                    onTap: () => _tapTag(tag),
                  ),
                  tooltip: 'Search hashtag'));
            },
            unknown: (unknown) {
              spans.add(TextSpan(
                  text: bodyText, style: TextStyle(color: Colors.black)));
            },
          );
          break;
        }

        byteCurrent = facet.index.byteEnd;
      }
    }
    final left = utf8text.sublist(byteCurrent);
    spans.add(TextSpan(
        text: utf8.decode(left), style: TextStyle(color: Colors.black)));

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

  Widget _buildReply(bluesky.FeedView feedView) {
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

  Widget _buildFooter(bluesky.Post post) {
    final author = post.author;
    final postUrl =
        '${Define.bskyUrl}/profile/${author.handle}/post/${post.uri.rkey}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Tooltip(
          message: 'View on Bluesky',
          waitDuration: Duration(milliseconds: 500),
          child: TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
                DateFormat('H:mm yyyy-MM-dd').format(post.indexedAt.toLocal())),
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
              final day = post.indexedAt.toLocal();
              context.read<Model>().setSearchDay(day.year, day.month, day.day);
            },
          ),
        ),
      ],
    );
  }
}

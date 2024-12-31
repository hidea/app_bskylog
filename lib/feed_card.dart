import 'dart:convert';
import 'dart:io';

import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bskylog/embed_external.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bluesky/bluesky.dart' as bluesky;
import 'package:provider/provider.dart';

import 'avatar_icon.dart';
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

    final embedWidth =
        isDesktop ? 424.0 : MediaQuery.of(context).size.width - 80.0;

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (feed.reasonRepost && feed.feedAuthorDid != feed.authorDid)
            _buildRepost(),
          if (feed.replyDid.isNotEmpty) _buildReply(widget.feedView),
          SelectionArea(
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 16.0, right: 12.0),
              titleAlignment: ListTileTitleAlignment.top,
              leading: AvatarIcon(avatar: author.avatar, size: 20),
              title: Text.rich(
                TextSpan(
                    text: displayName,
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleMedium!.fontSize,
                        color: Colors.black),
                    children: [
                      WidgetSpan(child: SizedBox(width: 4)),
                      TextSpan(
                        text: '@${author.handle}',
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .fontSize,
                            color: Colors.black54),
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
                    post.embed!.when(
                        record: (bluesky.EmbedViewRecord record) =>
                            EmbedRecordWidget(
                              record,
                              width: embedWidth,
                              height: embedWidth,
                            ),
                        images: (bluesky.EmbedViewImages images) =>
                            EmbedImagesWidget(
                              images,
                              width: embedWidth,
                            ),
                        external: (bluesky.EmbedViewExternal external) =>
                            EmbedExternalWidget(
                              external,
                              width: embedWidth,
                              height: embedWidth * 9 / 16,
                            ),
                        recordWithMedia: (bluesky.EmbedViewRecordWithMedia
                                recordWithMedia) =>
                            EmbedRecordWithMediaWidget(
                              recordWithMedia,
                              width: embedWidth,
                              height: embedWidth,
                            ),
                        video: (EmbedVideoView video) => EmbedVideoWidget(
                              video,
                              width: embedWidth,
                              height: embedWidth * 9 / 16,
                            ),
                        unknown: (Map<String, dynamic> _) =>
                            const Text('unsupported embed')),
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
                    child: Text(
                      bodyText,
                      style: TextStyle(color: Colors.blue),
                      textScaler: TextScaler.linear(1.0),
                    ),
                    onTap: () => _tapMention(mention),
                  ),
                  tooltip: 'Search mention'));
            },
            link: (link) {
              spans.add(TooltipSpan(
                  child: InkWell(
                    child: Text(
                      bodyText,
                      style: TextStyle(color: Colors.blue),
                      textScaler: TextScaler.linear(1.0),
                    ),
                    onTap: () => _tapLink(link),
                  ),
                  tooltip: 'View link'));
            },
            tag: (tag) {
              spans.add(TooltipSpan(
                  child: InkWell(
                    child: Text(
                      bodyText,
                      style: TextStyle(color: Colors.blue),
                      textScaler: TextScaler.linear(1.0),
                    ),
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
          SizedBox(width: 40),
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

    final root = (feedView.reply!.root as bluesky.UReplyPostRecord).data;

    return Row(
      children: [
        SizedBox(width: 36),
        Tooltip(
          message: 'View on Bluesky',
          waitDuration: Duration(milliseconds: 500),
          child: TextButton(
            onPressed: () => launchUrlPlus(postUrl),
            style: TextButton.styleFrom(
                padding: EdgeInsets.all(4),
                visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
            child: Row(
              children: [
                Icon(Icons.reply, size: 16, color: Colors.blueGrey),
                SizedBox(width: 4),
                Text('reply to ', style: TextStyle(color: Colors.blueGrey)),
                Text(displayName, style: TextStyle(color: Colors.blueGrey)),
              ],
            ),
          ),
        ),
        Tooltip(
          message: 'Search reply chain',
          child: TextButton(
            onPressed: () =>
                context.read<Model>().setSearchKeyword(root.uri.toString()),
            style: TextButton.styleFrom(
                padding: EdgeInsets.all(4),
                visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: Colors.blueGrey),
                SizedBox(width: 4),
                Text('search', style: TextStyle(color: Colors.blueGrey)),
              ],
            ),
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
            style: TextButton.styleFrom(
                padding: EdgeInsets.all(4),
                visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
            child: Text(
                DateFormat('H:mm yyyy-MM-dd').format(post.indexedAt.toLocal())),
            onPressed: () => launchUrlPlus(postUrl),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 16,
          height: 16,
          child: IconButton(
            icon: const Icon(Icons.today),
            iconSize: 16,
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

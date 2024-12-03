import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bluesky;
import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bluesky/app_bsky_embed_record.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:bluesky/core.dart';
import 'package:bskylog/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'avatar_icon.dart';
import 'define.dart';
import 'embed_external.dart';
import 'embed_images.dart';
import 'embed_record_with_media.dart';
import 'embed_video.dart';
import 'model.dart';
import 'tooltip_span.dart';

class EmbedRecordWidget extends StatefulWidget {
  const EmbedRecordWidget(this.embed,
      {super.key, required this.width, required this.height});

  final bluesky.EmbedViewRecord embed;
  final double width;
  final double height;

  @override
  State<EmbedRecordWidget> createState() => _EmbedRecordWidgetState();
}

class _EmbedRecordWidgetState extends State<EmbedRecordWidget> {
  Widget _buildRecord(bluesky.EmbedViewRecordViewRecord record) {
    final post = record.value;
    final author = record.author;
    final embeds = record.embeds;
    final displayName =
        author.displayName != null && author.displayName!.isNotEmpty
            ? author.displayName!
            : author.handle;

    final embedWidth = widget.width - 36.0;

    return SizedBox(
      width: widget.width,
      child: Card.outlined(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectionArea(
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 16.0, right: 12.0),
                titleAlignment: ListTileTitleAlignment.top,
                leading: AvatarIcon(avatar: author.avatar, size: 12),
                title: RichText(
                  text: TextSpan(
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
                                  .bodySmall!
                                  .fontSize,
                              color: Colors.black54),
                        ),
                      ]),
                ),
                subtitle: _buildRecordText(post),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (embeds != null)
                      for (final embed in embeds)
                        embed.when(
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
                              const Text('unsupported embed'),
                        ),
                    _buildFooter(record),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratorView(bluesky.FeedGeneratorView view) {
    return SizedBox(
      width: widget.width,
      child: Card.outlined(
        child: SelectionArea(
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 16.0, right: 12.0),
            titleAlignment: ListTileTitleAlignment.top,
            leading: AvatarIcon(avatar: view.avatar, size: 24),
            title: Text(
              view.displayName,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                  color: Colors.black),
            ),
            subtitle: Text(
              'feed by @${view.createdBy.handle}',
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                  color: Colors.black54),
            ),
            onTap: () {
              launchUrlPlus(
                  '${Define.bskyUrl}/profile/${view.createdBy.handle}/feed/${view.uri.rkey}');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildListView(bluesky.ListView view) {
    return SizedBox(
      width: widget.width,
      child: Card.outlined(
        child: SelectionArea(
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 16.0, right: 12.0),
            titleAlignment: ListTileTitleAlignment.top,
            leading: AvatarIcon(avatar: view.avatar, size: 24),
            title: Text(
              view.name,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                  color: Colors.black),
            ),
            subtitle: Text(
              'list by @${view.createdBy.handle}',
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                  color: Colors.black54),
            ),
            onTap: () {
              launchUrlPlus(
                  '${Define.bskyUrl}/profile/${view.createdBy.handle}/lists/${view.uri.rkey}');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStarterPack(StarterPackViewBasic view) {
    return SizedBox(
      width: widget.width,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: SelectionArea(
          child: InkWell(
            onTap: () {
              launchUrlPlus(
                  'https://bsky.app/starter-pack/${view.creator.handle}/${view.uri.rkey}');
            },
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl:
                      'https://ogcard.cdn.bsky.app/start/${view.creator.handle}/${view.uri.rkey}',
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 4),
                ListTile(
                  contentPadding:
                      const EdgeInsets.only(left: 16.0, right: 12.0),
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: AvatarIcon(avatar: view.creator.avatar, size: 16),
                  title: Text(
                    view.record.name,
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleMedium!.fontSize,
                        color: Colors.black),
                  ),
                  subtitle: Text(
                    '@${view.creator.handle}\'s startar pack',
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleSmall!.fontSize,
                        color: Colors.black54),
                  ),
                ),
                if (view.record.description?.isNotEmpty ?? false)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      view.record.description!,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordBreak(String text, AtUri _) {
    return SizedBox(
      width: widget.width,
      child: Card.outlined(
        child: SelectionArea(
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 16.0, right: 12.0),
            leading: Icon(Icons.info_outline),
            title: Text(text),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.embed.record.when(
      record: (bluesky.EmbedViewRecordViewRecord data) => _buildRecord(data),
      notFound: (bluesky.EmbedViewRecordViewNotFound data) =>
          _buildRecordBreak('Deleted', data.uri),
      blocked: (bluesky.EmbedViewRecordViewBlocked data) =>
          _buildRecordBreak('Blocked', data.uri),
      viewDetached: (EmbedRecordViewDetached data) =>
          _buildRecordBreak('Removed', data.uri),
      generatorView: (bluesky.FeedGeneratorView data) =>
          _buildGeneratorView(data),
      listView: (bluesky.ListView data) => _buildListView(data),
      starterPackViewBasic: (StarterPackViewBasic data) =>
          _buildStarterPack(data),
      labelerView: (bluesky.LabelerView _) => Container(),
      unknown: (Map<String, dynamic> _) => Container(),
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
        if (facet.index.byteStart < byteCurrent) {
          if (kDebugMode) {
            print(
                'invalid facet: current:$byteCurrent start:${facet.index.byteStart}');
          }
          continue;
        }
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

  Widget _buildFooter(bluesky.EmbedViewRecordViewRecord record) {
    final post = record;
    final author = record.author;
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

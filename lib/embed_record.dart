import 'dart:convert';

import 'package:bluesky/core.dart';
import 'package:bskylog/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bluesky;
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
  Widget _buildRecord(bluesky.UEmbedViewRecordViewRecord record) {
    final post = record.data.value;
    final author = record.data.author;
    final embeds = record.data.embeds;
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
                        switch (embed) {
                          (bluesky.UEmbedViewRecord record) =>
                            EmbedRecordWidget(
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
                          (bluesky.UEmbedViewImages images) =>
                            EmbedImagesWidget(
                              images.data,
                              width: embedWidth,
                            ),
                          (bluesky.UEmbedViewExternal external) =>
                            EmbedExternalWidget(
                              external.data,
                              width: embedWidth,
                              height: embedWidth * 9 / 16,
                            ),
                          (bluesky.UEmbedViewVideo video) => EmbedVideoWidget(
                              video.data,
                              width: embedWidth,
                              height: embedWidth * 9 / 16,
                            ),
                          bluesky.EmbedView() =>
                            const Text('unsupported embed'),
                        },
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

  Widget _buildGeneratorView(bluesky.UEmbedViewRecordViewGeneratorView view) {
    return SizedBox(
      width: widget.width,
      child: Card.outlined(
        child: SelectionArea(
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 16.0, right: 12.0),
            titleAlignment: ListTileTitleAlignment.top,
            leading: AvatarIcon(avatar: view.data.avatar, size: 24),
            title: Text(
              view.data.displayName,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                  color: Colors.black),
            ),
            subtitle: Text(
              'feed by @${view.data.createdBy.handle}',
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                  color: Colors.black54),
            ),
            onTap: () {
              launchUrlPlus(
                  '${Define.bskyUrl}/profile/${view.data.createdBy.handle}/feed/${view.data.uri.rkey}');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildListView(bluesky.UEmbedViewRecordViewListView view) {
    return SizedBox(
      width: widget.width,
      child: Card.outlined(
        child: SelectionArea(
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 16.0, right: 12.0),
            titleAlignment: ListTileTitleAlignment.top,
            leading: AvatarIcon(avatar: view.data.avatar, size: 24),
            title: Text(
              view.data.name,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                  color: Colors.black),
            ),
            subtitle: Text(
              'list by @${view.data.createdBy.handle}',
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                  color: Colors.black54),
            ),
            onTap: () {
              launchUrlPlus(
                  '${Define.bskyUrl}/profile/${view.data.createdBy.handle}/lists/${view.data.uri.rkey}');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRecordBreak(String text, AtUri uri) {
    return Text('$text ${uri.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.embed.record) {
      (bluesky.UEmbedViewRecordViewRecord record) => _buildRecord(record),
      (bluesky.UEmbedViewRecordViewNotFound notFound) => _buildRecordBreak(
          'Quoted post not found, it may have been deleted.',
          notFound.data.uri),
      (bluesky.UEmbedViewRecordViewBlocked blocked) =>
        _buildRecordBreak('The quoted post is blocked.', blocked.data.uri),
      (bluesky.UEmbedViewRecordViewViewDetached _) => Container(),
      (bluesky.UEmbedViewRecordViewGeneratorView generatorView) =>
        _buildGeneratorView(generatorView),
      (bluesky.UEmbedViewRecordViewListView listView) =>
        _buildListView(listView),
      (bluesky.UEmbedViewRecordViewLabelerView _) => Container(),
      bluesky.EmbedViewRecordView() => Container(),
    };
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

  Widget _buildFooter(bluesky.UEmbedViewRecordViewRecord record) {
    final post = record.data;
    final author = record.data.author;
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

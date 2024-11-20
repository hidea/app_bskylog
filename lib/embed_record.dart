import 'dart:convert';

import 'package:bluesky/core.dart';
import 'package:bskylog/utils.dart';
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

    final embedWidth = widget.width - 80.0;

    return SizedBox(
      width: widget.width,
      //height: widget.height,
      child: Card.outlined(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectionArea(
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.top,
                leading: AvatarIcon(avatar: author.avatar, size: 12),
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
                subtitle: _buildRecordText(post),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 50),
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
    return Text('generator view');
  }

  Widget _buildListView(bluesky.UEmbedViewRecordViewListView view) {
    return Text('list view');
  }

  Widget _buildLabelerView(bluesky.UEmbedViewRecordViewLabelerView view) {
    return Text('labeler view');
  }

  Widget _buildRecordBreak(String text, AtUri uri) {
    return Text('$text ${uri.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.embed.record) {
      (bluesky.UEmbedViewRecordViewRecord record) => _buildRecord(record),
      (bluesky.UEmbedViewRecordViewNotFound notFound) =>
        _buildRecordBreak('record not found', notFound.data.uri),
      (bluesky.UEmbedViewRecordViewBlocked blocked) =>
        _buildRecordBreak('record blocked', blocked.data.uri),
      (bluesky.UEmbedViewRecordViewViewDetached viewDetached) =>
        _buildRecordBreak('record detached', viewDetached.data.uri),
      (bluesky.UEmbedViewRecordViewGeneratorView generatorView) =>
        _buildGeneratorView(generatorView),
      (bluesky.UEmbedViewRecordViewListView listView) =>
        _buildListView(listView),
      (bluesky.UEmbedViewRecordViewLabelerView labelerView) =>
        _buildLabelerView(labelerView),
      bluesky.EmbedViewRecordView() => const Text('unsupport embed record'),
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

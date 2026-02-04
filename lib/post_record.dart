import 'dart:convert';

import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:bluesky/app_bsky_richtext_facet.dart' as bsky_facet;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'tooltip_span.dart';

class PostRecordWidget extends StatefulWidget {
  const PostRecordWidget(
      {required this.record,
      required this.onMention,
      required this.onLink,
      required this.onTag,
      super.key});

  final FeedPostRecord record;
  final void Function(bsky_facet.RichtextFacetMention) onMention;
  final void Function(bsky_facet.RichtextFacetLink) onLink;
  final void Function(bsky_facet.RichtextFacetTag) onTag;

  @override
  State<PostRecordWidget> createState() => _PostRecordWidgetState();
}

class _PostRecordWidgetState extends State<PostRecordWidget> {
  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final utf8text = utf8.encode(record.text);

    List<InlineSpan> spans = [];
    int byteCurrent = 0;

    if (record.facets != null && record.facets!.isNotEmpty) {
      final facets = record.facets!;
      //facets.sort((a, b) => a.index.byteStart - b.index.byteStart);

      for (final facet in facets) {
        final byteStart = facet.index.byteStart < byteCurrent
            ? byteCurrent
            : facet.index.byteStart;
        final byteEnd = facet.index.byteEnd > utf8text.length
            ? utf8text.length
            : facet.index.byteEnd;
        if (byteStart >= byteEnd) {
          if (kDebugMode) {
            print('invalid facet: start:$byteStart end:$byteEnd');
          }
          continue;
        }

        if (byteCurrent < byteStart) {
          final intro = utf8text.sublist(byteCurrent, byteStart);
          spans.add(TextSpan(
              text: utf8.decode(intro), style: TextStyle(color: Colors.black)));
        }

        final body = utf8text.sublist(byteStart, byteEnd);
        final bodyText = utf8.decode(body);

        for (final feature in facet.features) {
          feature.when(
            richtextFacetMention: (mention) {
              spans.add(TooltipSpan(
                  child: InkWell(
                    child: Text(
                      bodyText,
                      style: TextStyle(color: Colors.blue),
                      textScaler: TextScaler.linear(1.0),
                    ),
                    onTap: () => widget.onMention(mention),
                  ),
                  tooltip: 'Search mention'));
            },
            richtextFacetLink: (link) {
              spans.add(TooltipSpan(
                  child: InkWell(
                    child: Text(
                      bodyText,
                      style: TextStyle(color: Colors.blue),
                      textScaler: TextScaler.linear(1.0),
                    ),
                    onTap: () => widget.onLink(link),
                  ),
                  tooltip: 'View link'));
            },
            richtextFacetTag: (tag) {
              spans.add(TooltipSpan(
                  child: InkWell(
                    child: Text(
                      bodyText,
                      style: TextStyle(color: Colors.blue),
                      textScaler: TextScaler.linear(1.0),
                    ),
                    onTap: () => widget.onTag(tag),
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

        byteCurrent = byteEnd;
      }
    }
    final left = utf8text.sublist(byteCurrent);
    spans.add(TextSpan(
        text: utf8.decode(left), style: TextStyle(color: Colors.black)));

    return Text.rich(TextSpan(children: spans));
  }
}

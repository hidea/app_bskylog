import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bskylog/database.dart';
import 'package:bskylog/embed_external.dart';
import 'package:bskylog/embed_images.dart';
import 'package:bskylog/embed_record.dart';
import 'package:bskylog/embed_video.dart';
import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bluesky;

class EmbedRecordWithMediaWidget extends StatefulWidget {
  const EmbedRecordWithMediaWidget(this.feed, this.embed,
      {super.key, required this.width, required this.height});

  final Post feed;
  final bluesky.EmbedViewRecordWithMedia embed;
  final double width;
  final double height;

  @override
  State<EmbedRecordWithMediaWidget> createState() =>
      _EmbedRecordWithMediaWidgetState();
}

class _EmbedRecordWithMediaWidgetState
    extends State<EmbedRecordWithMediaWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.embed.media.when(
          images: (bluesky.EmbedViewImages images) =>
              EmbedImagesWidget(widget.feed, images, width: widget.width),
          external: (bluesky.EmbedViewExternal external) => EmbedExternalWidget(
              widget.feed, external,
              width: widget.width, height: widget.height),
          video: (EmbedVideoView video) => EmbedVideoWidget(widget.feed, video,
              width: widget.width, height: widget.height),
          unknown: (Map<String, dynamic> _) =>
              const Text('unsupport embed record media'),
        ),
        const SizedBox(height: 10),
        EmbedRecordWidget(widget.feed, widget.embed.record,
            width: widget.width, height: widget.height),
      ],
    );
  }
}

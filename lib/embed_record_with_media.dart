import 'package:bskylog/embed_external.dart';
import 'package:bskylog/embed_images.dart';
import 'package:bskylog/embed_record.dart';
import 'package:bskylog/embed_video.dart';
import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bluesky;

class EmbedRecordWithMediaWidget extends StatefulWidget {
  const EmbedRecordWithMediaWidget(this.embed,
      {super.key, required this.width, required this.height});

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
      children: [
        switch (widget.embed.media) {
          (bluesky.UEmbedViewMediaImages images) => EmbedImagesWidget(
              images.data,
              width: widget.width,
              height: widget.height),
          (bluesky.UEmbedViewMediaExternal external) => EmbedExternalWidget(
              external.data,
              width: widget.width,
              height: widget.height),
          (bluesky.UEmbedViewMediaVideo video) => EmbedVideoWidget(video.data,
              width: widget.width, height: widget.height),
          bluesky.EmbedViewMedia() =>
            const Text('unsupport embed record media'),
        },
        EmbedRecordWidget(widget.embed.record,
            width: widget.width, height: widget.height),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bluesky;

class EmbedImagesWidget extends StatefulWidget {
  const EmbedImagesWidget(this.embed, {super.key});

  final bluesky.EmbedViewImages embed;

  @override
  State<EmbedImagesWidget> createState() => _EmbedImagesWidgettState();
}

class _EmbedImagesWidgettState extends State<EmbedImagesWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (final image in widget.embed.images)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Image.network(
              image.fullsize,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}

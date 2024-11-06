import 'package:bskylog/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bluesky;

class EmbedExternalWidget extends StatefulWidget {
  const EmbedExternalWidget(this.embed, {super.key});

  final bluesky.EmbedViewExternal embed;

  @override
  State<EmbedExternalWidget> createState() => _EmbedExternalWidgetState();
}

class _EmbedExternalWidgetState extends State<EmbedExternalWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SelectionArea(
        child: InkWell(
          onTap: () {
            launchUrlPlus(widget.embed.external.uri);
          },
          child: SizedBox(
            width: 360,
            child: Column(
              children: [
                if (widget.embed.external.thumbnail != null)
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: CachedNetworkImage(
                      imageUrl: widget.embed.external.thumbnail!,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    Uri.parse(widget.embed.external.uri).host,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    widget.embed.external.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    widget.embed.external.description,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
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
}

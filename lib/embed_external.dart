import 'package:bskylog/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bluesky;

class EmbedExternalWidget extends StatefulWidget {
  const EmbedExternalWidget(this.embed,
      {super.key, required this.width, required this.height});

  final bluesky.EmbedViewExternal embed;
  final double width;
  final double height;

  @override
  State<EmbedExternalWidget> createState() => _EmbedExternalWidgetState();
}

class _EmbedExternalWidgetState extends State<EmbedExternalWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: SelectionArea(
          child: InkWell(
            onTap: () {
              launchUrlPlus(widget.embed.external.uri);
            },
            child: Column(
              children: [
                if (widget.embed.external.thumbnail != null)
                  SizedBox(
                    width: double.infinity,
                    height: widget.height,
                    child: CachedNetworkImage(
                      imageUrl: widget.embed.external.thumbnail!,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.public, size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 2),
                      Text(
                        Uri.parse(widget.embed.external.uri).host,
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .fontSize,
                            color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    widget.embed.external.title.isNotEmpty
                        ? widget.embed.external.title
                        : widget.embed.external.uri,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.embed.external.description.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      widget.embed.external.description,
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
}

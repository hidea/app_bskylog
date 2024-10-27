import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bluesky;

class ExternalEmbedWidget extends StatefulWidget {
  const ExternalEmbedWidget(this.embed, {super.key});

  final bluesky.EmbedViewExternal embed;

  @override
  State<ExternalEmbedWidget> createState() => _ExternalEmbedWidgetState();
}

class _ExternalEmbedWidgetState extends State<ExternalEmbedWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: 400,
        child: Column(
          children: [
            if (widget.embed.external.thumbnail != null)
              SizedBox(
                width: double.infinity,
                height: 100,
                child: Image.network(
                  widget.embed.external.thumbnail!,
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
    );
  }
}

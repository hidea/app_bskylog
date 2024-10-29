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
    return SizedBox(
      width: 360,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final image in widget.embed.images)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  child: Image.network(
                    image.fullsize,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: Text('image'),
                          ),
                          body: Center(
                            child: Image.network(
                              image.fullsize,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

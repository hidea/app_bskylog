import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bluesky;

class EmbedImagesWidget extends StatefulWidget {
  const EmbedImagesWidget(this.embed,
      {super.key, required this.width, required this.height});

  final bluesky.EmbedViewImages embed;
  final double width;
  final double height;

  @override
  State<EmbedImagesWidget> createState() => _EmbedImagesWidgetState();
}

class _EmbedImagesWidgetState extends State<EmbedImagesWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final image in widget.embed.images)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  child: CachedNetworkImage(
                    imageUrl: image.thumbnail,
                    height: widget.height,
                    fit: BoxFit.cover,
                  ),
                  onTap: () => Navigator.push(context, _imageViewRoute(image)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Route _imageViewRoute(bluesky.EmbedViewImagesView image) {
    return MaterialPageRoute(
      builder: (context) => _ImageViewPage(
        images: widget.embed.images,
        initialIndex: widget.embed.images.indexOf(image),
      ),
    );
  }
}

class _ImageViewPage extends StatefulWidget {
  const _ImageViewPage(
      {super.key, required this.images, required this.initialIndex});

  final List<bluesky.EmbedViewImagesView> images;
  final int initialIndex;

  @override
  State<_ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<_ImageViewPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _updateImageIndex(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final length = widget.images.length;
    final image = widget.images[_currentIndex];

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Center(
            child: CachedNetworkImage(
              imageUrl: image.fullsize,
              fit: BoxFit.contain,
            ),
          ),
          if (length > 1 && _currentIndex > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton.filled(
                  icon: const Icon(Icons.keyboard_arrow_left),
                  onPressed: () {
                    _updateImageIndex(_currentIndex - 1);
                  },
                ),
              ),
            ),
          if (length > 1 && _currentIndex < length - 1)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton.filled(
                  icon: const Icon(Icons.keyboard_arrow_right),
                  onPressed: () {
                    _updateImageIndex(_currentIndex + 1);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

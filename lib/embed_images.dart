import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bluesky;

class EmbedImagesWidget extends StatefulWidget {
  const EmbedImagesWidget(this.embed, {super.key, required this.width});

  final bluesky.EmbedViewImages embed;
  final double width;

  @override
  State<EmbedImagesWidget> createState() => _EmbedImagesWidgetState();
}

class _EmbedImagesWidgetState extends State<EmbedImagesWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.embed.images.length == 1) {
      final width = widget.width;
      return _image(widget.embed.images[0], width, width * 9 / 16);
    } else if (widget.embed.images.length == 2) {
      final width = (widget.width - 2) / 2;
      return Row(
        children: [
          _image(widget.embed.images[0], width, width * 14 / 16),
          const SizedBox(width: 2),
          _image(widget.embed.images[1], width, width * 14 / 16),
        ],
      );
    } else if (widget.embed.images.length == 3) {
      final width = (widget.width - 2) / 2;
      final height = width * 16 / 14;
      return Row(
        children: [
          _image(widget.embed.images[0], width, height),
          const SizedBox(width: 2),
          Column(
            children: [
              _image(widget.embed.images[1], width, (height - 2) / 2),
              const SizedBox(height: 2),
              _image(widget.embed.images[2], width, (height - 2) / 2),
            ],
          ),
        ],
      );
    } else if (widget.embed.images.length == 4) {
      final width = (widget.width - 2) / 2;
      return Column(
        children: [
          Row(
            children: [
              _image(widget.embed.images[0], width, width * 2 / 4),
              const SizedBox(width: 2),
              _image(widget.embed.images[1], width, width * 2 / 4),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              _image(widget.embed.images[2], width, width * 2 / 4),
              const SizedBox(width: 2),
              _image(widget.embed.images[3], width, width * 2 / 4),
            ],
          ),
        ],
      );
    }
    return Container();
  }

  Widget _image(
      bluesky.EmbedViewImagesView image, double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: InkWell(
        child: CachedNetworkImage(
          imageUrl: image.thumbnail,
          //height: height,
          fit: BoxFit.cover,
        ),
        onTap: () => Navigator.push(context, _imageViewRoute(image)),
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

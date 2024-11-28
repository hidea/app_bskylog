import 'package:bskylog/search_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/foundation.dart';
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
          fit: BoxFit.cover,
        ),
        onTap: () {
          final multiImageProvider = MultiImageProvider(
            [
              for (final i in widget.embed.images)
                CachedNetworkImageProvider(i.fullsize),
            ],
            initialIndex: widget.embed.images.indexOf(image),
          );
          if (isDesktop) {
            Navigator.push(context, _imageViewRoute(multiImageProvider));
          } else {
            showImageViewerPager(
              context,
              multiImageProvider,
              swipeDismissible: true,
              doubleTapZoomable: true,
            );
          }
        },
      ),
    );
  }

  Route _imageViewRoute(MultiImageProvider multiImageProvider) {
    return MaterialPageRoute(
      builder: (context) =>
          _ImageViewPage(multiImageProvider: multiImageProvider),
    );
  }
}

class _ImageViewPage extends StatefulWidget {
  const _ImageViewPage({required this.multiImageProvider});

  final MultiImageProvider multiImageProvider;

  @override
  State<_ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<_ImageViewPage> {
  late int _currentIndex = widget.multiImageProvider.initialIndex;
  late final _pageController =
      PageController(initialPage: widget.multiImageProvider.initialIndex);
  static const _kDuration = Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page?.toInt() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageCount = widget.multiImageProvider.imageCount;

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          EasyImageViewPager(
            easyImageProvider: widget.multiImageProvider,
            pageController: _pageController,
          ),
          if (imageCount > 1 && _currentIndex > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton.filled(
                  icon: const Icon(Icons.keyboard_arrow_left),
                  onPressed: () {
                    final currentPage = _pageController.page?.toInt() ?? 0;
                    _pageController.animateToPage(
                      currentPage > 0 ? currentPage - 1 : 0,
                      duration: _kDuration,
                      curve: _kCurve,
                    );
                  },
                ),
              ),
            ),
          if (imageCount > 1 && _currentIndex < imageCount - 1)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton.filled(
                  icon: const Icon(Icons.keyboard_arrow_right),
                  onPressed: () {
                    final currentPage = _pageController.page?.toInt() ?? 0;
                    final lastPage = imageCount - 1;
                    _pageController.animateToPage(
                      currentPage < lastPage ? currentPage + 1 : lastPage,
                      duration: _kDuration,
                      curve: _kCurve,
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

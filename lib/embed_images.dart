import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:bluesky/app_bsky_embed_images.dart';
import 'package:bskylog/database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'main.dart';
import 'model.dart';

class EmbedImagesWidget extends StatefulWidget {
  const EmbedImagesWidget(this.feed, this.embed,
      {super.key, required this.width});

  final Post feed;
  final EmbedImagesView embed;
  final double width;

  @override
  State<EmbedImagesWidget> createState() => _EmbedImagesWidgetState();
}

class _EmbedImagesWidgetState extends State<EmbedImagesWidget> {
  static double fourImagesHeight(double width) {
    final itemWidth = (width - 2) / 2;
    return itemWidth + 2;
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<Model>().visibleImage) {
      return Row(
        children: [
          for (final image in widget.embed.images)
            SizedBox(
              width: 24,
              height: 24,
              child: IconButton(
                icon: const Icon(Icons.image),
                iconSize: 24,
                padding: EdgeInsets.zero,
                tooltip: image.alt,
                onPressed: () => _onTapImage(image),
              ),
            ),
        ],
      );
    }

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
    } else if (widget.embed.images.length > 4) {
      return _EmbedImagesCarouselWidget(
        widget.embed,
        width: widget.width,
        height: fourImagesHeight(widget.width),
        onTapImage: _onTapImage,
      );
    }
    return Container();
  }

  Widget _image(EmbedImagesViewImage image, double width, double height) {
    return InkWell(
      child: Stack(
        children: [
          SizedBox(
            width: width,
            height: height,
            child: CachedNetworkImage(
              imageUrl: image.thumb,
              fit: BoxFit.cover,
            ),
          ),
          if (image.alt.isNotEmpty)
            Positioned(
              bottom: 2,
              right: 2,
              child: Tooltip(
                message: image.alt,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ALT',
                    style: TextStyle(fontSize: 8, color: Colors.black),
                  ),
                ),
              ),
            ),
        ],
      ),
      onTap: () => _onTapImage(image),
    );
  }

  void _onTapImage(EmbedImagesViewImage image) {
    if (isDesktop) {
      Navigator.push(context, _imageViewRoute(image));
    } else {
      _showImageViewerPager(image);
    }
  }

  void _showImageViewerPager(EmbedImagesViewImage image) {
    final multiImageProvider = MultiImageProvider(
      [
        for (final i in widget.embed.images)
          CachedNetworkImageProvider(i.fullsize),
      ],
      initialIndex: widget.embed.images.indexOf(image),
    );
    showImageViewerPager(
      context,
      multiImageProvider,
      swipeDismissible: true,
      doubleTapZoomable: true,
    );
  }

  Route _imageViewRoute(EmbedImagesViewImage image) {
    final index = widget.embed.images.indexOf(image);
    return MaterialPageRoute(
      builder: (context) =>
          _ImageViewPage(initialIndex: index, images: widget.embed.images),
    );
  }
}

class _EmbedImagesCarouselWidget extends StatefulWidget {
  const _EmbedImagesCarouselWidget(
    this.embed, {
    required this.width,
    required this.height,
    required this.onTapImage,
  });

  final EmbedImagesView embed;
  final double width;
  final double height;
  final void Function(EmbedImagesViewImage image) onTapImage;

  @override
  State<_EmbedImagesCarouselWidget> createState() =>
      _EmbedImagesCarouselWidgetState();
}

class _EmbedImagesCarouselWidgetState
    extends State<_EmbedImagesCarouselWidget> {
  static const _gap = 4.0;
  late final ScrollController _scrollController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollOffset);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollOffset);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.embed.images;
    if (images.isEmpty) {
      return const SizedBox();
    }

    final contentExtent = _contentExtent(images);
    final canScrollForward = _canScrollForward(contentExtent);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: ListView.separated(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => const SizedBox(width: _gap),
              itemBuilder: (context, index) {
                final image = images[index];
                return InkWell(
                  onTap: () => widget.onTapImage(image),
                  child: SizedBox(
                    width: _itemWidth(image),
                    height: widget.height,
                    child: Stack(
                      children: [
                        _image(image),
                        if (image.alt.isNotEmpty)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Tooltip(
                              message: image.alt,
                              child: _badge('ALT'),
                            ),
                          ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: _badge('${index + 1}/${images.length}'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_scrollOffset > 1)
            Positioned(
              left: 4,
              top: widget.height / 2 - 14,
              child: _arrowButton(
                icon: Icons.chevron_left,
                onPressed: () => _scrollBy(-1, contentExtent),
              ),
            ),
          if (canScrollForward)
            Positioned(
              right: 4,
              top: widget.height / 2 - 14,
              child: _arrowButton(
                icon: Icons.chevron_right,
                onPressed: () => _scrollBy(1, contentExtent),
              ),
            ),
        ],
      ),
    );
  }

  void _updateScrollOffset() {
    if (!mounted) {
      return;
    }
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  double _contentExtent(List<EmbedImagesViewImage> images) {
    if (images.isEmpty) {
      return 0;
    }

    final imageWidths =
        images.fold<double>(0, (total, image) => total + _itemWidth(image));
    return imageWidths + _gap * (images.length - 1);
  }

  bool _canScrollForward(double contentExtent) {
    final maxScrollExtent = _maxScrollExtent(contentExtent);
    return _scrollOffset < maxScrollExtent - 1;
  }

  double _maxScrollExtent(double contentExtent) {
    if (_scrollController.hasClients) {
      return _scrollController.position.maxScrollExtent;
    }
    return (contentExtent - widget.width).clamp(0, double.infinity).toDouble();
  }

  double _itemWidth(EmbedImagesViewImage image) {
    final aspectRatio = image.aspectRatio;
    if (aspectRatio == null ||
        aspectRatio.width <= 0 ||
        aspectRatio.height <= 0) {
      return widget.height;
    }

    final width = widget.height * aspectRatio.width / aspectRatio.height;
    return width.clamp(widget.height * 0.6, widget.width * 0.86).toDouble();
  }

  void _scrollBy(int direction, double contentExtent) {
    final nextOffset = (_scrollOffset + direction * widget.width * 0.75)
        .clamp(0, _maxScrollExtent(contentExtent))
        .toDouble();
    _scrollController.animateTo(
      nextOffset,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  Widget _arrowButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: Colors.black.withValues(alpha: 0.72),
      child: IconButton(
        icon: Icon(icon),
        iconSize: 24,
        padding: EdgeInsets.zero,
        color: Colors.white,
        onPressed: onPressed,
      ),
    );
  }

  Widget _badge(String text) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _image(EmbedImagesViewImage image) {
    return Container(
      color: Colors.grey[100],
      child: CachedNetworkImage(
        imageUrl: image.thumb,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }
}

class _ImageViewPage extends StatefulWidget {
  const _ImageViewPage({required this.initialIndex, required this.images});

  final int initialIndex;
  final List<EmbedImagesViewImage> images;

  @override
  State<_ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<_ImageViewPage> {
  late final _multiImageProvider = MultiImageProvider([
    for (final i in widget.images) CachedNetworkImageProvider(i.fullsize),
  ], initialIndex: widget.initialIndex);
  late int _currentIndex = widget.initialIndex;
  late final _pageController = PageController(initialPage: widget.initialIndex);
  bool _isSaving = false;
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
    final imageCount = _multiImageProvider.imageCount;

    return Scaffold(
      appBar: AppBar(
        title:
            imageCount > 1 ? Text('${_currentIndex + 1} / $imageCount') : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy',
            onPressed: () => _copyToClipboard(),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Save',
            onPressed: () => _saveToDownload(),
          ),
        ],
      ),
      bottomNavigationBar: widget.images[_currentIndex].alt.isNotEmpty
          ? BottomAppBar(child: Text(widget.images[_currentIndex].alt))
          : null,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  EasyImageViewPager(
                    easyImageProvider: _multiImageProvider,
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
                            final currentPage =
                                _pageController.page?.toInt() ?? 0;
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
                            final currentPage =
                                _pageController.page?.toInt() ?? 0;
                            final lastPage = imageCount - 1;
                            _pageController.animateToPage(
                              currentPage < lastPage
                                  ? currentPage + 1
                                  : lastPage,
                              duration: _kDuration,
                              curve: _kCurve,
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard != null) {
      final uri = widget.images[_currentIndex].fullsize;
      final file = await DefaultCacheManager().getSingleFile(uri);
      final Uint8List imageData = file.readAsBytesSync();

      FutureOr<EncodedData>? data;
      Formats.png.mimeTypes;
      final mimeType = lookupMimeType('bytes', headerBytes: imageData);
      switch (mimeType) {
        case 'image/webp':
          data = Formats.webp(imageData);
          break;
        case 'image/png':
          data = Formats.png(imageData);
          break;
        case 'image/jpeg':
          data = Formats.jpeg(imageData);
          break;
      }
      if (data != null) {
        final item = DataWriterItem();
        item.add(data);
        await clipboard.write([item]);

        scaffoldMsgKey.currentState!.showSnackBar(SnackBar(
            content: Text("Copy to clipboard."),
            behavior: SnackBarBehavior.floating));
      }
    }
  }

  void _saveToDownload() async {
    setState(() {
      _isSaving = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(value: 0.0),
        );
      },
    );

    try {
      final uri = widget.images[_currentIndex].fullsize;
      final file = await DefaultCacheManager().getSingleFile(uri);

      final outputFile = await FilePicker.saveFile(
        type: FileType.image,
        dialogTitle: 'Please select image to save:',
        fileName: file.basename,
      );
      if (outputFile == null) {
        return null;
      }
      await file.copy(outputFile);

      scaffoldMsgKey.currentState!.showSnackBar(SnackBar(
          content: Text("Save done."),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'open image',
            onPressed: () => launchUrlString('file://$outputFile'),
          ),
          showCloseIcon: true,
          duration: const Duration(days: 365)));
    } catch (e) {
      scaffoldMsgKey.currentState!.showSnackBar(SnackBar(
          content: Text("Export failed.\n$e"),
          showCloseIcon: true,
          duration: const Duration(days: 365)));
    } finally {
      setState(() {
        _isSaving = false;
      });
      Navigator.of(context).pop();
    }
  }
}

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bluesky/bluesky.dart' as bluesky;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mime/mime.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'main.dart';

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
          if (isDesktop) {
            Navigator.push(context, _imageViewRoute(image));
          } else {
            _showImageViewerPager(image);
          }
        },
      ),
    );
  }

  void _showImageViewerPager(bluesky.EmbedViewImagesView image) {
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

  Route _imageViewRoute(bluesky.EmbedViewImagesView image) {
    final index = widget.embed.images.indexOf(image);
    return MaterialPageRoute(
      builder: (context) =>
          _ImageViewPage(initialIndex: index, images: widget.embed.images),
    );
  }
}

class _ImageViewPage extends StatefulWidget {
  const _ImageViewPage({required this.initialIndex, required this.images});

  final int initialIndex;
  final List<bluesky.EmbedViewImagesView> images;

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
      body: Stack(
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

      final outputFile = await FilePicker.platform.saveFile(
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

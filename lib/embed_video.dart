import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'model.dart';

class EmbedVideoWidget extends StatefulWidget {
  const EmbedVideoWidget(this.embed,
      {super.key, required this.width, required this.height});

  final EmbedVideoView embed;
  final double width;
  final double height;

  @override
  State<EmbedVideoWidget> createState() => _EmbedVideoWidgetState();
}

class _EmbedVideoWidgetState extends State<EmbedVideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.embed.playlist))
          ..initialize().then((_) {
            setState(() {
              _controller.setVolume(context.read<Model>().volume);
            });
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Container(
            constraints: BoxConstraints(
              maxWidth: widget.width,
              maxHeight: widget.height,
            ),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_controller),
                      _ControlsOverlay(controller: _controller),
                    ],
                  ),
                  VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (!widget.controller.value.isPlaying) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
              ? const SizedBox.shrink()
              : const ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              widget.controller.value.isPlaying
                  ? widget.controller.pause()
                  : widget.controller.play();
            });
          },
        ),
        IconButton(
          icon: widget.controller.value.volume == 0
              ? const Icon(Icons.volume_off, color: Colors.white)
              : const Icon(Icons.volume_up, color: Colors.white),
          onPressed: () {
            setState(() {
              widget.controller
                  .setVolume(widget.controller.value.volume == 0 ? 1 : 0);
            });
          },
        ),
      ],
    );
  }
}

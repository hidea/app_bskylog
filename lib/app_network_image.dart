import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

ImageProvider appNetworkImageProvider(String url) {
  if (kIsWeb) {
    return NetworkImage(
      url,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
    );
  }
  return CachedNetworkImageProvider(url);
}

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext context, String url, Object error)?
      errorWidget;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: errorWidget == null
            ? null
            : (context, error, stackTrace) =>
                errorWidget!(context, imageUrl, error),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorWidget: errorWidget,
    );
  }
}

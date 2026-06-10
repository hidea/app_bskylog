import 'package:bluesky/app_bsky_embed_images.dart';
import 'package:bluesky/app_bsky_embed_defs.dart' as bsky_embed;

EmbedImagesView? embedImagesViewFromGallery(Map<String, dynamic> data) {
  final type = data[r'$type'];
  if (type != 'app.bsky.embed.gallery' &&
      type != 'app.bsky.embed.gallery#view') {
    return null;
  }

  final rawItems = data['items'];
  if (rawItems is! List) {
    return null;
  }

  final images = <EmbedImagesViewImage>[];
  for (final rawItem in rawItems) {
    if (rawItem is! Map) {
      continue;
    }

    final item = Map<String, dynamic>.from(rawItem);
    final thumb = item['thumbnail'] ?? item['thumb'];
    final fullsize = item['fullsize'] ?? thumb;
    if (thumb is! String || fullsize is! String) {
      continue;
    }

    images.add(
      EmbedImagesViewImage(
        $type: 'app.bsky.embed.images#viewImage',
        thumb: thumb,
        fullsize: fullsize,
        alt: item['alt'] is String ? item['alt'] as String : '',
        aspectRatio: _aspectRatioFrom(item['aspectRatio']),
      ),
    );
  }

  if (images.isEmpty) {
    return null;
  }

  return EmbedImagesView(
    $type: 'app.bsky.embed.images#view',
    images: images,
  );
}

bsky_embed.AspectRatio? _aspectRatioFrom(Object? value) {
  if (value is! Map) {
    return null;
  }

  return bsky_embed.AspectRatio.fromJson(Map<String, Object?>.from(value));
}

bool isGalleryEmbed(Object? embed) {
  if (embed is! Map) {
    return false;
  }

  final type = embed[r'$type'];
  return type == 'app.bsky.embed.gallery' ||
      type == 'app.bsky.embed.gallery#view';
}

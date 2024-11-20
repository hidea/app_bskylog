import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarIcon extends StatelessWidget {
  const AvatarIcon({super.key, this.avatar, this.size = 16});

  final String? avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = avatar != null && avatar != null
        ? CachedNetworkImageProvider(avatar!)
        : null;
    return avatar != null
        ? CircleAvatar(radius: size, backgroundImage: image)
        : Icon(Icons.account_circle, size: size * 2);
  }
}

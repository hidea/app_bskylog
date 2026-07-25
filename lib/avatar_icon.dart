import 'package:flutter/material.dart';

import 'app_network_image.dart';

class AvatarIcon extends StatelessWidget {
  const AvatarIcon({super.key, this.avatar, this.size = 16});

  final String? avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    return avatar != null
        ? CircleAvatar(
            radius: size,
            backgroundColor: Colors.grey.shade200,
            child: ClipOval(
              child: AppNetworkImage(
                imageUrl: avatar!,
                width: size * 2,
                height: size * 2,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    Icon(Icons.account_circle, size: size * 2),
              ),
            ),
          )
        : Icon(Icons.account_circle, size: size * 2);
  }
}

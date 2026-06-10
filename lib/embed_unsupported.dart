import 'package:flutter/material.dart';

class EmbedUnsupportedWidget extends StatelessWidget {
  const EmbedUnsupportedWidget({
    super.key,
    required this.width,
    this.data,
    this.title = 'Unsupported embed',
  });

  final double width;
  final Object? data;
  final String title;

  String? get _type {
    final data = this.data;
    if (data is Map) {
      final type = data[r'$type'];
      if (type is String && type.isNotEmpty) {
        return type;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final type = _type;

    return SizedBox(
      width: width,
      child: Card.outlined(
        child: SelectionArea(
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 16.0, right: 12.0),
            title: Text(title),
            subtitle: Text(
              type ?? 'This embed type is not supported yet.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ),
      ),
    );
  }
}

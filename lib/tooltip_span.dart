import 'package:flutter/material.dart';

class TooltipSpan extends WidgetSpan {
  TooltipSpan({required String tooltip, required Widget child})
      : super(
          alignment: PlaceholderAlignment.middle,
          child: Tooltip(
            message: tooltip,
            child: child,
          ),
        );
}

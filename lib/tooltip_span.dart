import 'package:flutter/material.dart';

class TooltipSpan extends WidgetSpan {
  TooltipSpan({required String tooltip, required Widget child})
      : super(child: Tooltip(message: tooltip, child: child));
}

import 'package:flutter/material.dart';

class RotationIcon extends StatefulWidget {
  const RotationIcon({super.key, required this.icon, this.syncing = false});

  final Widget icon;
  final bool syncing;

  @override
  State<RotationIcon> createState() => _RotationIconState();
}

class _RotationIconState extends State<RotationIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.syncing
        ? AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14,
                child: child,
              );
            },
            child: widget.icon,
          )
        : widget.icon;
  }
}

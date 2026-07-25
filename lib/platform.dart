import 'package:flutter/foundation.dart';

bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

bool get isDesktop =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows);

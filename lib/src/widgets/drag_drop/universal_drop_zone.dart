import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'desktop_drop_zone_desktop.dart';
import 'web_drop_zone.dart';

class UniversalDropZone extends StatelessWidget {
  final Widget child;
  final Future<void> Function(List<MediaItem> files)? onFilesDropped;
  final List<String> allowedExtensions;
  final bool showOverlay;
  final String? overlayText;
  final bool enabled;

  const UniversalDropZone({
    super.key,
    required this.child,
    this.onFilesDropped,
    required this.allowedExtensions,
    this.showOverlay = true,
    this.overlayText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    if (kIsWeb) {
      return WebDropZone(
        onFilesDropped: onFilesDropped,
        allowedExtensions: allowedExtensions,
        showOverlay: showOverlay,
        overlayText: overlayText,
        enabled: enabled,
        child: child,
      );
    } else {
      return DesktopDropZone(
        onFilesDropped: onFilesDropped,
        allowedExtensions: allowedExtensions,
        showOverlay: showOverlay,
        overlayText: overlayText,
        enabled: enabled,
        child: child,
      );
    }
  }
}

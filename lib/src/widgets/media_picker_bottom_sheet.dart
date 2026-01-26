import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';

class MediaPickerBottomSheet {
  static Future<List<MediaItem>?> open(
    BuildContext context, {
    List<MediaItem> initialSelection = const [],
    int maxSelection = 10,
    bool allowMultiple = true,
    bool showVideos = true,
    double initialChildSize = 0.6,
    double minChildSize = 0.4,
    double maxChildSize = 0.9,
  }) async {
    final isWeb = kIsWeb;
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    if (isWeb || isDesktop) {
      return showDialog<List<MediaItem>>(
        context: context,
        builder: (_) => MediaPickerDialog(
          initialSelection: initialSelection,
          maxSelection: maxSelection,
          allowMultiple: allowMultiple,
          showVideos: showVideos,
        ),
      );
    }

    return showModalBottomSheet<List<MediaItem>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: MediaPickerScreen(
              initialSelection: initialSelection,
              maxSelection: maxSelection,
              allowMultiple: allowMultiple,
              showVideos: showVideos,
              showDragHandle: true,
              showCancelButton: true,
              forceWebDesktopLayout: false,
            ),
          );
        },
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/widgets/media_picker_dialog.dart';
import 'package:media_ui_package/src/widgets/media_picker_screen.dart';

class MediaPickerBottomSheet extends StatelessWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool showSelectionIndicators;
  final MediaPickerConfig config;
  final DeviceMediaLibrary mediaLibrary;
  final void Function(List<MediaItem>)? onSelectionChanged;
  final void Function(List<MediaItem>)? onConfirmed;
  final void Function(List<MapEntry<MediaItem, Uint8List?>>)?
  onConfirmedWithBytes;

  const MediaPickerBottomSheet({
    super.key,
    required this.initialSelection,
    required this.maxSelection,
    required this.allowMultiple,
    required this.showVideos,
    required this.initialChildSize,
    required this.minChildSize,
    required this.maxChildSize,
    required this.showSelectionIndicators,
    required this.config,
    required this.mediaLibrary,
    this.onSelectionChanged,
    this.onConfirmed,
    this.onConfirmedWithBytes,
  });

  static Future<List<MediaItem>?> open({
    required BuildContext context,
    List<MediaItem> initialSelection = const [],
    int maxSelection = 10,
    bool allowMultiple = true,
    bool showVideos = true,
    double initialChildSize = 0.7,
    double minChildSize = 0.4,
    double maxChildSize = 0.9,
    bool showSelectionIndicators = true,
    MediaPickerConfig? config,
    DeviceMediaLibrary? mediaLibrary,
    void Function(List<MediaItem>)? onSelectionChanged,
    void Function(List<MediaItem>)? onConfirmed,
    void Function(List<MapEntry<MediaItem, Uint8List?>>)? onConfirmedWithBytes,
  }) async {
    final isWeb = kIsWeb;
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    final actualMediaLibrary = mediaLibrary ?? DeviceMediaLibrary();
    final actualConfig = config ?? const MediaPickerConfig();

    // Helper function to convert bytes to media items
    Future<List<MediaItem>> _getMediaItems(
      List<MapEntry<MediaItem, Uint8List?>> entries,
    ) async {
      return entries.map((entry) => entry.key).toList();
    }

    if (isWeb || isDesktop) {
      return showDialog<List<MediaItem>>(
        context: context,
        builder: (_) => MediaPickerDialog(
          initialSelection: initialSelection,
          maxSelection: maxSelection,
          allowMultiple: allowMultiple,
          showVideos: showVideos,
          showSelectionIndicators: showSelectionIndicators,
          config: actualConfig,
          mediaLibrary: actualMediaLibrary,
          onSelectionChanged: onSelectionChanged,
          onConfirmed: onConfirmed,
          onConfirmedWithBytes: onConfirmedWithBytes,
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
              showSelectionIndicators: showSelectionIndicators,
              config: actualConfig,
              mediaLibrary: actualMediaLibrary,
              onSelectionChanged: onSelectionChanged,
              // Convert the callback type
              onConfirmed: (entriesWithBytes) async {
                // Call onConfirmedWithBytes if provided
                onConfirmedWithBytes?.call(entriesWithBytes);

                // Call onConfirmed with just media items
                final mediaItems = entriesWithBytes.map((e) => e.key).toList();
                onConfirmed?.call(mediaItems);

                // Return media items for the bottom sheet
                Navigator.of(context).pop(mediaItems);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

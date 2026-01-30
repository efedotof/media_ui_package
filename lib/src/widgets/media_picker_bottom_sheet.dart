import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/upload_media_request.dart';

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
  final void Function(List<UploadMediaRequest>)? onConfirmedWithRequests;

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
    this.onConfirmedWithRequests,
  });

  static Future<List<UploadMediaRequest>?> open({
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
    void Function(List<UploadMediaRequest>)? onConfirmedWithRequests,
  }) async {
    final isWeb = kIsWeb;
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    final actualMediaLibrary = mediaLibrary ?? DeviceMediaLibrary();
    final actualConfig = config ?? const MediaPickerConfig();

    if (isWeb || isDesktop) {
      return showDialog<List<UploadMediaRequest>>(
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
          onConfirmedWithRequests: onConfirmedWithRequests,
        ),
      );
    }

    final result = await showModalBottomSheet<List<MediaItem>>(
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
              onConfirmed: (selectedItems) async {
                final utilsMedia = UtilsMedia();
                final requests = <UploadMediaRequest>[];
                for (final item in selectedItems) {
                  final request = await utilsMedia.createUploadRequest(item);
                  if (request != null) {
                    requests.add(request);
                  }
                }
                if (context.mounted) {
                  Navigator.of(context).pop(requests);
                }
              },
            ),
          );
        },
      ),
    );

    if (result != null && onConfirmedWithRequests != null) {
      final utilsMedia = UtilsMedia();
      final requests = <UploadMediaRequest>[];
      for (final item in result) {
        final request = await utilsMedia.createUploadRequest(item);
        if (request != null) {
          requests.add(request);
        }
      }
      onConfirmedWithRequests(requests);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

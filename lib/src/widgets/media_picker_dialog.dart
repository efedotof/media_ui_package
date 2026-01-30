import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/generated/l10n.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'package:media_ui_package/src/models/upload_media_request.dart';

class MediaPickerDialog extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final bool showSelectionIndicators;
  final MediaPickerConfig config;
  final DeviceMediaLibrary mediaLibrary;
  final void Function(List<MediaItem>)? onSelectionChanged;
  final void Function(List<UploadMediaRequest>)? onConfirmedWithRequests;

  const MediaPickerDialog({
    super.key,
    required this.initialSelection,
    required this.maxSelection,
    required this.allowMultiple,
    required this.showVideos,
    required this.showSelectionIndicators,
    required this.config,
    required this.mediaLibrary,
    this.onSelectionChanged,
    this.onConfirmedWithRequests,
  });

  @override
  State<MediaPickerDialog> createState() => _MediaPickerDialogState();
}

class _MediaPickerDialogState extends State<MediaPickerDialog> {
  late MediaGridCubit _mediaGridCubit;
  final UtilsMedia _utilsMedia = UtilsMedia();

  @override
  void initState() {
    super.initState();

    final mediaType = widget.showVideos ? MediaType.all : MediaType.images;
    _mediaGridCubit = MediaGridCubit(
      mediaType: mediaType,
      albumId: null,
      thumbnailBuilder: null,
      allowMultiple: widget.allowMultiple,
      maxSelection: widget.maxSelection,
      initialSelection: widget.initialSelection,
    )..init();
  }

  @override
  void dispose() {
    _mediaGridCubit.close();
    super.dispose();
  }

  Future<List<UploadMediaRequest>> _getUploadRequests(
    List<MediaItem> items,
  ) async {
    final result = <UploadMediaRequest>[];

    for (final item in items) {
      try {
        final request = await _utilsMedia.createUploadRequest(item);
        if (request != null) {
          result.add(request);
        }
      } catch (e) {
        debugPrint('Error creating upload request for ${item.uri}: $e');
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mediaGridCubit,
      child: BlocListener<MediaGridCubit, MediaGridState>(
        listener: (context, state) {
          state.whenOrNull(
            loaded:
                (
                  mediaItems,
                  thumbnailCache,
                  hasMoreItems,
                  currentOffset,
                  isLoadingMore,
                  showSelectionIndicators,
                  selectedMediaItems,
                ) {
                  widget.onSelectionChanged?.call(selectedMediaItems);
                },
          );
        },
        child: MediaPickerConfigScope(
          config: widget.config,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.config.borderRadius),
            ),
            child: SizedBox(
              width: 520,
              height: 520,
              child: Column(
                children: [
                  AppBar(
                    title: Text(S.of(context).selectMedia),
                    automaticallyImplyLeading: false,
                    actions: [
                      BlocBuilder<MediaGridCubit, MediaGridState>(
                        builder: (context, state) {
                          final cubit = context.read<MediaGridCubit>();
                          final selected = cubit.selectedItems;

                          return TextButton(
                            onPressed: selected.isEmpty
                                ? null
                                : () async {
                                    final requests = await _getUploadRequests(
                                      selected,
                                    );
                                    if (context.mounted) {
                                      Navigator.of(context).pop(selected);
                                      widget.onConfirmedWithRequests?.call(
                                        requests,
                                      );
                                    }
                                  },
                            child: Text(S.of(context).confirm),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: MediaGrid(autoPlayVideosInFullscreen: true)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

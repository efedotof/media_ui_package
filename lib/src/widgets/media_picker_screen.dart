import 'dart:typed_data' show Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'selection_app_bar.dart';

class MediaPickerScreen extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final String title;
  final Function(List<MediaItem>)? onSelectionChanged;
  final Uint8List? Function(MediaItem)? thumbnailBuilder;
  final String? albumId;
  final MediaType mediaType;
  final MediaPickerConfig? config;

  const MediaPickerScreen({
    super.key,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.title = 'Select Media',
    this.onSelectionChanged,
    this.thumbnailBuilder,
    this.albumId,
    this.mediaType = MediaType.all,
    this.config,
  });

  @override
  State<MediaPickerScreen> createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen> {
  @override
  Widget build(BuildContext context) {
    final config = widget.config ?? const MediaPickerConfig();

    final mediaType = widget.mediaType == MediaType.all
        ? (widget.showVideos ? MediaType.all : MediaType.images)
        : widget.mediaType;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MediaGridCubit(
            mediaType: mediaType,
            albumId: widget.albumId,
            thumbnailBuilder: widget.thumbnailBuilder,
            allowMultiple: widget.allowMultiple,
            maxSelection: widget.maxSelection,
            initialSelection: widget.initialSelection,
          )..init(),
        ),
      ],
      child: MediaPickerConfigScope(
        config: config,
        child: Builder(
          builder: (context) {
            return BlocConsumer<MediaGridCubit, MediaGridState>(
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
              builder: (context, state) {
                final selectedCount = state.when(
                  initial: () => 0,
                  loading: () => 0,
                  permissionRequesting: () => 0,
                  permissionDenied: () => 0,
                  loaded:
                      (
                        mediaItems,
                        thumbnailCache,
                        hasMoreItems,
                        currentOffset,
                        isLoadingMore,
                        showSelectionIndicators,
                        selectedMediaItems,
                      ) => selectedMediaItems.length,
                  error: (message) => 0,
                );

                return Scaffold(
                  appBar: SelectionAppBar(
                    title: widget.title,
                    selectedCount: selectedCount,
                    maxSelection: widget.maxSelection,
                    onClear: () =>
                        context.read<MediaGridCubit>().clearSelection(),
                    onDone: () => _confirmSelection(context),
                  ),
                  body: const MediaGrid(),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _confirmSelection(BuildContext context) {
    final selectedItems = context.read<MediaGridCubit>().selectedItems;
    Navigator.of(context).pop(selectedItems);
  }
}

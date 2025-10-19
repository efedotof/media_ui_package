import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';

class MediaPickerDialog extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final Function(List<MediaItem>)? onSelectionChanged;
  final Function(List<MediaItem>)? onConfirmed;
  final MediaPickerConfig? config;

  const MediaPickerDialog({
    super.key,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.onSelectionChanged,
    this.onConfirmed,
    this.config,
  });

  @override
  State<MediaPickerDialog> createState() => _MediaPickerDialogState();
}

class _MediaPickerDialogState extends State<MediaPickerDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = widget.config ?? const MediaPickerConfig();
    final mediaType = widget.showVideos ? MediaType.all : MediaType.images;

    void confirmSelection() {
      final selectedItems = context.read<MediaGridCubit>().selectedItems;
      Navigator.of(context).pop(selectedItems);
      widget.onConfirmed?.call(selectedItems);
    }

    void cancelSelection() {
      Navigator.of(context).pop();
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MediaGridCubit(
            mediaType: mediaType,
            albumId: null,
            thumbnailBuilder: null,
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
            return BlocListener<MediaGridCubit, MediaGridState>(
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
              child: Dialog(
                backgroundColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                insetPadding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 600,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocBuilder<MediaGridCubit, MediaGridState>(
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

                          return Container(
                            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Choose media',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.allowMultiple
                                            ? 'Up to ${widget.maxSelection} items'
                                            : 'Select one item',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withAlpha(6),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.allowMultiple && selectedCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withAlpha(1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$selectedCount',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: cancelSelection,
                                  style: IconButton.styleFrom(
                                    padding: const EdgeInsets.all(4),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const Divider(height: 1),

                      const Expanded(child: MediaGrid()),

                      BlocBuilder<MediaGridCubit, MediaGridState>(
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

                          final hasSelection = selectedCount > 0;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: cancelSelection,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colorScheme.onSurface,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      side: BorderSide(
                                        color: colorScheme.outline.withAlpha(3),
                                      ),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: hasSelection
                                        ? confirmSelection
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasSelection
                                          ? colorScheme.primary
                                          : colorScheme.onSurface.withAlpha(12),
                                      foregroundColor: hasSelection
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface.withAlpha(38),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (selectedCount > 0 &&
                                            widget.allowMultiple)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              right: 6,
                                            ),
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: colorScheme.onPrimary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '$selectedCount',
                                              style: TextStyle(
                                                color: colorScheme.primary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        Text(
                                          widget.allowMultiple
                                              ? 'Confirm'
                                              : 'Select',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

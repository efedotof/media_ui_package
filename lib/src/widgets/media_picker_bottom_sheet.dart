import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';

class MediaPickerBottomSheet extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final Function(List<MediaItem>)? onSelectionChanged;
  final Function(List<MediaItem>)? onConfirmed;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool showSelectionIndicators;
  final MediaPickerConfig? config;

  const MediaPickerBottomSheet({
    super.key,
    this.showSelectionIndicators = true,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.onSelectionChanged,
    this.onConfirmed,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.4,
    this.maxChildSize = 0.9,
    this.config,
  });

  @override
  State<MediaPickerBottomSheet> createState() => _MediaPickerBottomSheetState();
}

class _MediaPickerBottomSheetState extends State<MediaPickerBottomSheet> {
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
            return DraggableScrollableSheet(
              initialChildSize: widget.initialChildSize,
              minChildSize: widget.minChildSize,
              maxChildSize: widget.maxChildSize,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withAlpha(3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

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

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Select Media',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.allowMultiple
                                            ? 'Select up to ${widget.maxSelection} items'
                                            : 'Select one item',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withAlpha(6),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (selectedCount > 0) ...[
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
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: () => context
                                        .read<MediaGridCubit>()
                                        .clearSelection(),
                                    style: TextButton.styleFrom(
                                      foregroundColor: colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                    child: Text(
                                      'Clear',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),

                      const Divider(height: 1),

                      Expanded(
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
                                    widget.onSelectionChanged?.call(
                                      selectedMediaItems,
                                    );
                                  },
                            );
                          },
                          child: const MediaGrid(),
                        ),
                      ),

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
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(1),
                                  blurRadius: 8,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colorScheme.onSurface,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      side: BorderSide(
                                        color: colorScheme.outline.withAlpha(3),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
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
                                          : colorScheme.primary.withAlpha(4),
                                      foregroundColor: colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (selectedCount > 0 &&
                                            widget.allowMultiple) ...[
                                          Container(
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '$selectedCount',
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                        Text(
                                          widget.allowMultiple
                                              ? 'Confirm'
                                              : 'Select',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}

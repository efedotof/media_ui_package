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
  final double? borderRadius;

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
    this.borderRadius,
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
    final isDark = theme.brightness == Brightness.dark;

    final borderRadius = widget.borderRadius != null
        ? BorderRadius.circular(widget.borderRadius!)
        : BorderRadius.zero;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MediaGridCubit(
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
                    color: isDark ? Colors.white70 : Colors.black87,
                    borderRadius: borderRadius,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: MediaGrid(autoPlayVideosInFullscreen: true),
                      ),

                      BlocBuilder<MediaGridCubit, MediaGridState>(
                        builder: (context, state) {
                          final cubit = context.read<MediaGridCubit>();
                          final selected = cubit.selectedItems;
                          final hasSelection = selected.isNotEmpty;

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.close_rounded),
                                  color: colorScheme.onSurface,
                                  tooltip: 'Cancel',
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: hasSelection
                                      ? () {
                                          widget.onConfirmed?.call(selected);

                                          Navigator.of(context).pop(selected);
                                        }
                                      : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: hasSelection
                                          ? colorScheme.primary
                                          : colorScheme.surfaceContainerHighest,
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: hasSelection
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
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

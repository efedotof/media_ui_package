import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'selection_indicator_widget.dart';
import 'video_info_widget.dart';
import 'thumbnail/thumbnail_widget.dart';

class MediaGridItem extends StatelessWidget {
  final MediaItem item;
  final ColorScheme colorScheme;
  final bool isSelected;
  final int selectionIndex;
  final VoidCallback onSelect;
  final VoidCallback onThumbnailTap;

  const MediaGridItem({
    super.key,
    required this.item,
    required this.colorScheme,
    required this.isSelected,
    required this.selectionIndex,
    required this.onSelect,
    required this.onThumbnailTap,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MediaGridCubit>();
    final thumbnail = cubit.getThumbnail(item);
    final isLoading = cubit.isThumbnailLoading(item);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: colorScheme.primary, width: 2)
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(30),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ThumbnailWidget(
            onThumbnailTap: onThumbnailTap,
            colorScheme: colorScheme,
            isLoading: isLoading,
            item: item,
            onRetryLoad: () => _retryLoadThumbnail(context, item),
            thumbnail: thumbnail,
          ),
          SelectionIndicatorWidget(
            config: const MediaPickerConfig(),
            colorScheme: colorScheme,
            onSelectionTap: onSelect,
            isSelected: isSelected,
            selectionIndex: selectionIndex,
          ),
          VideoInfoWidget(item: item, colorScheme: colorScheme),
        ],
      ),
    );
  }

  void _retryLoadThumbnail(BuildContext context, MediaItem item) {
    context.read<MediaGridCubit>().loadTumbunail(item);
  }
}

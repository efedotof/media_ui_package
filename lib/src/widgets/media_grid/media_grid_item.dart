import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'selection_indicator_widget.dart';
import 'video_info_widget.dart';

class MediaGridItem extends StatefulWidget {
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
  State<MediaGridItem> createState() => _MediaGridItemState();
}

class _MediaGridItemState extends State<MediaGridItem> {
  late Future<Uint8List?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  void _loadThumbnail() {
    final cubit = context.read<MediaGridCubit>();

    if (!cubit.isThumbnailLoaded(widget.item) &&
        !cubit.hasThumbnailError(widget.item)) {
      _thumbnailFuture = cubit.getThumbnailFuture(widget.item);
    } else {
      _thumbnailFuture = Future.value(cubit.getThumbnail(widget.item));
    }
  }

  void _retryLoadThumbnail() {
    final cubit = context.read<MediaGridCubit>();
    setState(() {
      _thumbnailFuture = cubit.getThumbnailFuture(widget.item);
      cubit.loadTumbunail(widget.item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MediaGridCubit>();
    final isLoaded = cubit.isThumbnailLoaded(widget.item);
    final isLoading = cubit.isThumbnailLoading(widget.item);
    final hasError = cubit.hasThumbnailError(widget.item);

    return GestureDetector(
      onTap: widget.onThumbnailTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: widget.isSelected
              ? Border.all(color: widget.colorScheme.primary, width: 3)
              : null,
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: widget.colorScheme.primary.withAlpha(50),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildThumbnailContent(isLoaded, isLoading, hasError),
            SelectionIndicatorWidget(
              config: const MediaPickerConfig(),
              colorScheme: widget.colorScheme,
              onSelectionTap: widget.onSelect,
              isSelected: widget.isSelected,
              selectionIndex: widget.selectionIndex,
            ),
            if (widget.item.type == 'video')
              VideoInfoWidget(
                item: widget.item,
                colorScheme: widget.colorScheme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailContent(bool isLoaded, bool isLoading, bool hasError) {
    if (isLoaded) {
      final cubit = context.read<MediaGridCubit>();
      final thumbnail = cubit.getThumbnail(widget.item);

      if (thumbnail != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.memory(
            thumbnail,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        );
      }
    }

    if (hasError) {
      return _buildErrorPlaceholder();
    }

    return FutureBuilder<Uint8List?>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
          return _buildLoadingPlaceholder();
        }

        if (snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          );
        }

        return _buildErrorPlaceholder();
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: widget.colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(widget.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return GestureDetector(
      onTap: _retryLoadThumbnail,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: widget.colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.item.type == 'video' ? Icons.videocam : Icons.photo,
              color: widget.colorScheme.onSurface.withAlpha(150),
              size: 32,
            ),
            const SizedBox(height: 6),
            Icon(Icons.refresh, color: widget.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

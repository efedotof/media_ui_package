import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'selection_indicator_widget.dart';
import 'video_info_widget.dart';
import 'thumbnail_widget.dart';

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
  final ValueNotifier<Uint8List?> _thumbnail = ValueNotifier(null);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final bytes = context.read<MediaGridCubit>().getThumbnail(widget.item);
      _thumbnail.value = bytes;
    } catch (_) {
      _thumbnail.value = null;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: _thumbnail,
      builder: (_, thumbnail, __) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border.all(color: widget.colorScheme.primary, width: 2)
                : null,
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.colorScheme.primary.withAlpha(3),
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
                onThumbnailTap: widget.onThumbnailTap, 
                colorScheme: widget.colorScheme,
                isLoading: _isLoading,
                item: widget.item,
                onRetryLoad: _loadThumbnail,
                thumbnail: thumbnail,
              ),
              SelectionIndicatorWidget(
                config: const MediaPickerConfig(),
                colorScheme: widget.colorScheme,
                onSelectionTap: widget.onSelect, 
                isSelected: widget.isSelected,
                selectionIndex: widget.selectionIndex,
              ),
              VideoInfoWidget(
                item: widget.item,
                colorScheme: widget.colorScheme,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _thumbnail.dispose();
    super.dispose();
  }
}
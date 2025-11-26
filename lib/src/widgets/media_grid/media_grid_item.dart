import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';

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
    final cubit = context.read<MediaGridCubit>();
    if (!cubit.isThumbnailLoaded(widget.item) &&
        !cubit.hasThumbnailError(widget.item)) {
      _thumbnailFuture = cubit.getThumbnailFuture(widget.item);
    } else {
      _thumbnailFuture = Future.value(cubit.getThumbnail(widget.item));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MediaGridCubit>();
    final isLoaded = cubit.isThumbnailLoaded(widget.item);
    final isLoading = cubit.isThumbnailLoading(widget.item);
    cubit.hasThumbnailError(widget.item);

    return GestureDetector(
      onTap: widget.onThumbnailTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: widget.isSelected
              ? Border.all(color: widget.colorScheme.primary, width: 2)
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isLoaded && cubit.getThumbnail(widget.item) != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.memory(
                  cubit.getThumbnail(widget.item)!,
                  fit: BoxFit.cover,
                ),
              )
            else
              FutureBuilder<Uint8List?>(
                future: _thumbnailFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      isLoading) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: widget.colorScheme.surfaceContainerHighest,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: widget.colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _thumbnailFuture = cubit.getThumbnailFuture(
                            widget.item,
                          );
                          cubit.loadTumbunail(widget.item);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: widget.colorScheme.surfaceContainerHighest,
                        ),
                        child: Center(
                          child: Icon(
                            widget.item.type == 'video'
                                ? Icons.videocam
                                : Icons.photo,
                            size: 24,
                            color: widget.colorScheme.error,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),

            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: widget.onSelect,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? widget.colorScheme.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  child: widget.isSelected
                      ? Center(
                          child: Text(
                            '${widget.selectionIndex}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const Icon(Icons.add, color: Colors.white, size: 14),
                ),
              ),
            ),

            if (widget.item.type == 'video')
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  color: Colors.black54,
                  child: const Icon(
                    Icons.videocam,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

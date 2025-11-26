import 'dart:typed_data' show Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';

class MediaPickerScreen extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
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
                  loaded: (_, __, ___, ____, _____, ______, selected) {
                    widget.onSelectionChanged?.call(selected);
                  },
                );
              },
              builder: (context, state) {
                final selected = state.maybeWhen(
                  loaded: (_, __, ___, ____, _____, ______, s) => s,
                  orElse: () => <MediaItem>[],
                );
                final hasSelection = selected.isNotEmpty;

                return Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.surface,

                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.check_rounded),
                        onPressed: hasSelection
                            ? () => _confirmSelection(context)
                            : null,
                        color: hasSelection
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
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

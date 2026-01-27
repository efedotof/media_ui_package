import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/generated/l10n.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';

class MediaPickerScreen extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final bool showDragHandle;
  final bool showCancelButton;
  final bool forceWebDesktopLayout;
  final bool showSelectionIndicators;
  final MediaPickerConfig config;
  final DeviceMediaLibrary mediaLibrary;
  final void Function(List<MediaItem>)? onSelectionChanged;
  final void Function(List<MapEntry<MediaItem, Uint8List?>>) onConfirmed;

  const MediaPickerScreen({
    super.key,
    required this.initialSelection,
    required this.maxSelection,
    required this.allowMultiple,
    required this.showVideos,
    this.showDragHandle = false,
    this.showCancelButton = true,
    this.forceWebDesktopLayout = false,
    required this.showSelectionIndicators,
    required this.config,
    required this.mediaLibrary,
    this.onSelectionChanged,
    required this.onConfirmed,
  });

  @override
  State<MediaPickerScreen> createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen> {
  late List<MediaItem> selectedItems;

  bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    selectedItems = [...widget.initialSelection];
  }

  Future<List<MapEntry<MediaItem, Uint8List?>>> _getFilesWithBytes(
    List<MediaItem> items,
  ) async {
    final result = <MapEntry<MediaItem, Uint8List?>>[];

    for (final item in items) {
      try {
        final bytes = await widget.mediaLibrary.getFileBytes(item.uri);
        result.add(MapEntry(item, bytes));
      } catch (e) {
        result.add(MapEntry(item, null));
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forceWebDesktopLayout || !isMobile) {
      return _buildWebDesktopPicker();
    } else {
      return _buildMobileMediaPicker();
    }
  }

  Widget _buildMobileMediaPicker() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaType = widget.showVideos ? MediaType.all : MediaType.images;

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
        config: widget.config,
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
              child: Column(
                children: [
                  if (widget.showDragHandle) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S.of(context).selectMedia,
                          style: theme.textTheme.titleLarge,
                        ),
                        if (widget.showCancelButton)
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                            color: colorScheme.onSurface,
                            tooltip: S.of(context).cancel,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: MediaGrid(autoPlayVideosInFullscreen: true)),
                  BlocBuilder<MediaGridCubit, MediaGridState>(
                    builder: (context, state) {
                      final cubit = context.read<MediaGridCubit>();
                      final selected = cubit.selectedItems;
                      final hasSelection = selected.isNotEmpty;

                      return SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                          child: Row(
                            children: [
                              if (selected.isNotEmpty)
                                Text(
                                  '${selected.length}/${widget.maxSelection}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              const Spacer(),
                              OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(S.of(context).cancel),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: hasSelection
                                    ? () async {
                                        if (context.mounted) {
                                          final filesWithBytes =
                                              await _getFilesWithBytes(
                                                selected,
                                              );
                                          if (context.mounted) {
                                            Navigator.of(
                                              context,
                                            ).pop(filesWithBytes);
                                          }
                                        }
                                      }
                                    : null,
                                child: Text(S.of(context).confirm),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWebDesktopPicker() {
    final theme = Theme.of(context);

    return MediaPickerConfigScope(
      config: widget.config,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).selectMedia),
          actions: [
            TextButton(
              onPressed: selectedItems.isEmpty
                  ? null
                  : () async {
                      if (context.mounted) {
                        final filesWithBytes = await _getFilesWithBytes(
                          selectedItems,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop(filesWithBytes);
                        }
                      }
                    },
              child: Text(S.of(context).confirm),
            ),
          ],
        ),
        body: Column(
          children: [
            if (selectedItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: theme.dividerColor, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${selectedItems.length}/${widget.maxSelection} выбранных',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    if (selectedItems.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedItems.clear();
                          });
                        },
                        child: const Text('Очистить все'),
                      ),
                  ],
                ),
              ),
            Expanded(child: MediaGrid(autoPlayVideosInFullscreen: true)),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
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
  final Function(List<MapEntry<String, Uint8List>>)? onConfirmed;
  final MediaPickerConfig? config;
  final Widget? child;
  final DeviceMediaLibrary? mediaLibrary;

  const MediaPickerDialog({
    super.key,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.onSelectionChanged,
    this.onConfirmed,
    this.config,
    this.child,
    this.mediaLibrary,
  });

  @override
  State<MediaPickerDialog> createState() => _MediaPickerDialogState();
}

class _MediaPickerDialogState extends State<MediaPickerDialog> {
  bool get _isWeb => kIsWeb;
  bool get _isWindows => !kIsWeb && Platform.isWindows;
  bool get _shouldUseMediaPickerUI => _isWeb || _isWindows;
  late DeviceMediaLibrary _mediaLibrary;

  @override
  void initState() {
    super.initState();
    _mediaLibrary = widget.mediaLibrary ?? DeviceMediaLibrary();
  }

  Future<List<MapEntry<String, Uint8List>>> _getFilesWithBytes(
    List<MediaItem> files,
  ) async {
    final result = <MapEntry<String, Uint8List>>[];

    for (final file in files) {
      try {
        final bytes = await _mediaLibrary.getFileBytes(file.uri);
        if (bytes != null && bytes.isNotEmpty) {
          result.add(MapEntry(file.uri, bytes));
        }
      } catch (e) {
        debugPrint('Error getting bytes for file ${file.uri}: $e');
      }
    }

    return result;
  }

  Future<void> _handleConfirmSelection(
    BuildContext context,
    List<MediaItem> selected,
  ) async {
    final filesWithBytes = await _getFilesWithBytes(selected);

    if (context.mounted) {
      widget.onConfirmed?.call(filesWithBytes);
      Navigator.of(context).pop(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldUseMediaPickerUI) {
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: MediaPickerUI(
          initialSelection: widget.initialSelection,
          maxSelection: widget.maxSelection,
          allowMultiple: widget.allowMultiple,
          showVideos: widget.showVideos,
          onFilesSelected: (files) async {
            final filesWithBytes = await _getFilesWithBytes(files);
            if (context.mounted) {
              widget.onConfirmed?.call(filesWithBytes);
              Navigator.of(context).pop();
            }
          },
          showPickButton: true,
          config: widget.config,
          child: widget.child ?? Container(),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final config = widget.config ?? const MediaPickerConfig();
    final mediaType = widget.showVideos ? MediaType.all : MediaType.images;

    void cancel() => Navigator.pop(context);

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
            final builderContext = context;
            return Dialog(
              insetPadding: const EdgeInsets.all(18),
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 600,
                  maxWidth: 500,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: cancel,
                          splashRadius: 22,
                        ),
                        const Spacer(),
                      ],
                    ),

                    const SizedBox(height: 4),

                    const Expanded(child: MediaGrid()),

                    BlocBuilder<MediaGridCubit, MediaGridState>(
                      builder: (context, state) {
                        final selected = state.maybeWhen(
                          loaded: (_, __, ___, ____, _____, ______, s) => s,
                          orElse: () => <MediaItem>[],
                        );
                        final hasSelection = selected.isNotEmpty;

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                          child: Row(
                            children: [
                              const Spacer(),
                              GestureDetector(
                                onTap: hasSelection
                                    ? () => _handleConfirmSelection(
                                        builderContext,
                                        selected,
                                      )
                                    : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.all(14),
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
              ),
            );
          },
        ),
      ),
    );
  }
}

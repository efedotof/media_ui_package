import 'dart:io';
import 'package:flutter/foundation.dart';
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
  final Function(List<MapEntry<String, Uint8List>>)? onConfirmed;
  final Uint8List? Function(MediaItem)? thumbnailBuilder;
  final String? albumId;
  final MediaType mediaType;
  final MediaPickerConfig? config;
  final Widget? child;
  final DeviceMediaLibrary? mediaLibrary;

  const MediaPickerScreen({
    super.key,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.onSelectionChanged,
    this.onConfirmed,
    this.thumbnailBuilder,
    this.albumId,
    this.mediaType = MediaType.all,
    this.config,
    this.child,
    this.mediaLibrary,
  });

  @override
  State<MediaPickerScreen> createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen> {
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

  void _handleConfirmSelection(
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
      return Scaffold(
        appBar: AppBar(
          title: const Text('Media Picker'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: MediaPickerUI(
          initialSelection: widget.initialSelection,
          maxSelection: widget.maxSelection,
          allowMultiple: widget.allowMultiple,
          showVideos: widget.showVideos,
          onFilesSelected: (files) async {
            final filesWithBytes = await _getFilesWithBytes(files);
            if (context.mounted) {
              widget.onConfirmed?.call(filesWithBytes);
              Navigator.of(context).pop(files);
            }
          },
          showPickButton: true,
          config: widget.config,
          child: widget.child ?? Container(),
        ),
      );
    }

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
            final builderContext = context;
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
                            ? () => _handleConfirmSelection(
                                builderContext,
                                selected,
                              )
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
}

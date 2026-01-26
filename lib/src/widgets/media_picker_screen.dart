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

  const MediaPickerScreen({
    super.key,
    required this.initialSelection,
    required this.maxSelection,
    required this.allowMultiple,
    required this.showVideos,
    this.showDragHandle = false,
    this.showCancelButton = true,
    this.forceWebDesktopLayout = false,
  });

  @override
  State<MediaPickerScreen> createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen> {
  late List<MediaItem> selectedFiles;

  bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    selectedFiles = [...widget.initialSelection];
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
      child: Builder(
        builder: (context) {
          return Column(
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
              Expanded(child: MediaGrid(autoPlayVideosInFullscreen: true)),
              BlocBuilder<MediaGridCubit, MediaGridState>(
                builder: (context, state) {
                  final cubit = context.read<MediaGridCubit>();
                  final selected = cubit.selectedItems;
                  final hasSelection = selected.isNotEmpty;

                  return SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
                      child: Row(
                        children: [
                          if (widget.showCancelButton)
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close_rounded),
                              color: colorScheme.onSurface,
                              tooltip: S.of(context).cancel,
                            ),
                          const Spacer(),
                          GestureDetector(
                            onTap: hasSelection
                                ? () {
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
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWebDesktopPicker() {
    Future<void> pickFilesFromDialog() async {
      final library = DeviceMediaLibrary();
      final result = await library.pickFiles(multiple: widget.allowMultiple);

      if (result == null) return;

      final mappedFiles = result.map((file) {
        return MediaItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: file['name']?.toString() ?? 'Unknown',
          uri: file['uri']?.toString() ?? file['filePath']?.toString() ?? '',
          dateAdded: DateTime.now().millisecondsSinceEpoch,
          size: file['size'] is int ? file['size'] : 0,
          width: file['width'] is int ? file['width'] : 0,
          height: file['height'] is int ? file['height'] : 0,
          albumId: file['albumId']?.toString() ?? '',
          albumName: file['albumName']?.toString() ?? '',
          type: file['type']?.toString() ?? 'image',
          duration: file['duration'] is int ? file['duration'] : null,
        );
      }).toList();

      setState(() {
        if (!widget.allowMultiple && mappedFiles.isNotEmpty) {
          selectedFiles
            ..clear()
            ..add(mappedFiles.first);
        } else {
          for (final f in mappedFiles) {
            if (selectedFiles.length < widget.maxSelection) {
              selectedFiles.add(f);
            }
          }
        }
      });
    }

    void confirmSelection() {
      Navigator.of(context).pop(selectedFiles);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).selectMedia),
        actions: [
          TextButton(
            onPressed: selectedFiles.isEmpty ? null : confirmSelection,
            child: Text(S.of(context).confirm),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: UniversalDropZone(
              enabled: true,
              allowedExtensions: const ['.jpg', '.jpeg', '.png', '.mp4'],
              onFilesDropped: (droppedFiles) async {
                setState(() {
                  for (final f in droppedFiles) {
                    if (selectedFiles.length < widget.maxSelection) {
                      selectedFiles.add(f);
                    }
                  }
                });
              },
              child: selectedFiles.isEmpty
                  ? Center(child: Text(S.of(context).dropFilesOrUseButtonBelow))
                  : ListView.builder(
                      itemCount: selectedFiles.length,
                      itemBuilder: (_, index) => ListTile(
                        title: Text(selectedFiles[index].name),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => selectedFiles.removeAt(index));
                          },
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: pickFilesFromDialog,
              icon: const Icon(Icons.folder_open),
              label: Text(S.of(context).chooseFiles),
            ),
          ),
        ],
      ),
    );
  }
}

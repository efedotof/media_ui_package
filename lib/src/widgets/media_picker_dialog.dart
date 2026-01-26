import 'package:flutter/material.dart';
import 'package:media_ui_package/generated/l10n.dart';
import 'package:media_ui_package/media_ui_package.dart';

class MediaPickerDialog extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;

  const MediaPickerDialog({
    super.key,
    required this.initialSelection,
    required this.maxSelection,
    required this.allowMultiple,
    required this.showVideos,
  });

  @override
  State<MediaPickerDialog> createState() => _MediaPickerDialogState();
}

class _MediaPickerDialogState extends State<MediaPickerDialog> {
  late List<MediaItem> _selectedFiles;

  @override
  void initState() {
    super.initState();
    _selectedFiles = [...widget.initialSelection];
  }

  Future<void> _pickFiles() async {
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
        _selectedFiles
          ..clear()
          ..add(mappedFiles.first);
      } else {
        for (final f in mappedFiles) {
          if (_selectedFiles.length < widget.maxSelection) {
            _selectedFiles.add(f);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 520,
        height: 520,
        child: Column(
          children: [
            AppBar(
              title: Text(S.of(context).selectMedia),
              automaticallyImplyLeading: false,
              actions: [
                TextButton(
                  onPressed: _selectedFiles.isEmpty
                      ? null
                      : () {
                          Navigator.of(context).pop(_selectedFiles);
                        },
                  child: Text(S.of(context).confirm),
                ),
              ],
            ),
            Expanded(
              child: UniversalDropZone(
                enabled: true,
                allowedExtensions: const ['.jpg', '.jpeg', '.png', '.mp4'],
                onFilesDropped: (droppedFiles) async {
                  setState(() {
                    for (final f in droppedFiles) {
                      if (_selectedFiles.length < widget.maxSelection) {
                        _selectedFiles.add(f);
                      }
                    }
                  });
                },
                child: _selectedFiles.isEmpty
                    ? Center(
                        child: Text(S.of(context).dropFilesOrUseButtonBelow),
                      )
                    : ListView.builder(
                        itemCount: _selectedFiles.length,
                        itemBuilder: (_, index) => ListTile(
                          title: Text(_selectedFiles[index].name),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedFiles.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.folder_open),
                label: Text(S.of(context).chooseFiles),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

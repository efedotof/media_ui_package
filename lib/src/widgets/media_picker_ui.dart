import 'package:flutter/material.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/upload_media_request.dart';
import 'package:media_ui_package/src/widgets/media_picker_widget.dart';

class MediaPickerUI extends StatefulWidget {
  final Widget child;
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final Function(List<MediaItem>)? onFilesSelected;
  final Function(List<UploadMediaRequest>)? onUploadRequests;
  final bool showPickButton;
  final bool enableDragDrop;
  final MediaPickerConfig? config;

  const MediaPickerUI({
    super.key,
    required this.child,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.onFilesSelected,
    this.onUploadRequests,
    this.showPickButton = true,
    this.enableDragDrop = true,
    this.config,
  });

  @override
  State<MediaPickerUI> createState() => _MediaPickerUIState();
}

class _MediaPickerUIState extends State<MediaPickerUI> {
  final List<MediaItem> _selectedFiles = [];
  final GlobalKey<MediaPickerWidgetState> _pickerWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedFiles.addAll(widget.initialSelection);
  }

  Future<void> pickFiles() async {
    if (_pickerWidgetKey.currentState != null) {
      await _pickerWidgetKey.currentState!.pickFiles();
    }
  }

  Future<void> _handleSelectedFiles(List<MediaItem> files) async {
    if (!mounted) return;

    setState(() {
      _selectedFiles.clear();
      _selectedFiles.addAll(files);
    });

    widget.onFilesSelected?.call(_selectedFiles);
  }

  Future<void> _handleUploadRequests(List<UploadMediaRequest> requests) async {
    if (!mounted) return;

    final mediaItems = requests
        .map(
          (req) => MediaItem(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: req.fileName,
            uri: 'temp://${req.fileName}',
            dateAdded: DateTime.now().millisecondsSinceEpoch,
            size: req.bytes.length,
            width: 0,
            height: 0,
            albumId: '',
            albumName: '',
            type: _getTypeFromFileName(req.fileName),
          ),
        )
        .toList();

    setState(() {
      _selectedFiles.clear();
      _selectedFiles.addAll(mediaItems);
    });

    widget.onFilesSelected?.call(_selectedFiles);
    widget.onUploadRequests?.call(requests);
  }

  String _getTypeFromFileName(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm')) {
      return 'video';
    }
    return 'image';
  }

  @override
  Widget build(BuildContext context) {
    return MediaPickerWidget(
      key: _pickerWidgetKey,
      initialSelection: _selectedFiles,
      maxSelection: widget.maxSelection,
      allowMultiple: widget.allowMultiple,
      showVideos: widget.showVideos,
      onSelectionChanged: _handleSelectedFiles,
      onConfirmedWithRequests: _handleUploadRequests,
      enableDragDrop: widget.enableDragDrop,
      config: widget.config,
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),

          if (widget.showPickButton)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: pickFiles,
                child: const Icon(Icons.add_photo_alternate),
              ),
            ),
        ],
      ),
    );
  }
}

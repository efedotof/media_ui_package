import 'package:flutter/material.dart';
import 'package:media_ui_package/src/models/media_source.dart';

class EmptyView extends StatelessWidget {
  final MediaSource source;

  const EmptyView({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;

    switch (source) {
      case MediaSource.device:
        message = 'Нет медиафайлов';
        icon = Icons.photo_library_outlined;
        break;
      case MediaSource.downloads:
        message = 'Нет файлов в Download';
        icon = Icons.download_outlined;
        break;
      case MediaSource.documents:
        message = 'Нет файлов в Documents';
        icon = Icons.folder_outlined;
        break;
      case MediaSource.picked:
      case MediaSource.dropped:
        message = 'Файлы не выбраны';
        icon = Icons.upload_file_outlined;
        break;
      case MediaSource.unknown:
        message = 'Пусто';
        icon = Icons.folder_off_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}

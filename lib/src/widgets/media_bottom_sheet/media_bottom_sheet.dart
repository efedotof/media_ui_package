import 'package:flutter/material.dart';
import 'package:media_ui_package/src/themes/media_picker_theme.dart';

import '../../models/media_picker_result.dart';
import '../media_picker_widget/media_picker_widget.dart';
import 'drag_handle.dart';

class MediaPickerBottomSheet {
  MediaPickerBottomSheet._();

  static Future<MediaPickerResult?> show(
    BuildContext context, {
    String title = 'Выбрать медиа',
    String confirmLabel = 'Готово',
    bool multiSelect = true,
    bool recursive = false,
    MediaPickerSection initialSection = MediaPickerSection.media,
    List<MediaPickerSection> sections = const [
      MediaPickerSection.media,
      MediaPickerSection.audio,
      MediaPickerSection.downloads,
      MediaPickerSection.documents,
      MediaPickerSection.others,
    ],
    MediaPickerConfig? config,
    double initialChildSize = 0.85,
    double minChildSize = 0.4,
    double maxChildSize = 0.95,
    bool enableDrag = false,
  }) {
    return showModalBottomSheet<MediaPickerResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: enableDrag,
      builder: (sheetContext) {
        final pickerKey = GlobalKey<MediaPickerWidgetState>();

        MediaPickerResult? readSelection() {
          final r = pickerKey.currentState?.currentResult;
          if (r == null || r.isEmpty) return null;
          return r;
        }

        void close([MediaPickerResult? result]) {
          Navigator.of(sheetContext).pop(result);
        }

        Widget content = DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          expand: false,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    DragHandle(),
                    Expanded(
                      child: MediaPickerWidget(
                        key: pickerKey,
                        title: title,
                        confirmLabel: confirmLabel,
                        multiSelect: multiSelect,
                        recursive: recursive,
                        initialSection: initialSection,
                        sections: sections,
                        config: config,
                        onConfirm: close,
                        onCancel: () => close(readSelection()),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (config != null) {
          content = MediaPickerConfigScope(config: config, child: content);
        }

        return PopScope<MediaPickerResult>(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            close(readSelection());
          },
          child: content,
        );
      },
    );
  }
}

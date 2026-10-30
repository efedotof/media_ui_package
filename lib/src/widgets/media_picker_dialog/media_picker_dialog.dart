import 'package:flutter/material.dart';
import 'package:media_ui_package/src/themes/media_picker_theme.dart';

import '../../models/media_picker_result.dart';
import '../media_picker_widget/media_picker_widget.dart';

class MediaPickerDialog {
  MediaPickerDialog._();

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
    double? maxWidth,
    double? maxHeight,
  }) {
    return showDialog<MediaPickerResult>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);
        final width = maxWidth ?? (size.width * 0.92).clamp(320.0, 720.0);
        final height = maxHeight ?? (size.height * 0.88).clamp(400.0, 900.0);

        final pickerKey = GlobalKey<MediaPickerWidgetState>();

        MediaPickerResult? readSelection() {
          final r = pickerKey.currentState?.currentResult;
          if (r == null || r.isEmpty) return null;
          return r;
        }

        void close([MediaPickerResult? result]) {
          Navigator.of(dialogContext).pop(result);
        }

        Widget content = SizedBox(
          width: width,
          height: height,
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
          child: Dialog(
            clipBehavior: Clip.antiAlias,
            insetPadding: const EdgeInsets.all(16),
            child: content,
          ),
        );
      },
    );
  }
}

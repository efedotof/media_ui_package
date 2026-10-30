import 'package:flutter/material.dart';
import '../media_picker_widget/media_picker_widget.dart';

class BuildBottomMenu extends StatelessWidget {
  final List<MediaPickerSection> sections;
  final MediaPickerSection currentSection;
  final ValueChanged<MediaPickerSection> onSectionSwitch;

  const BuildBottomMenu({
    super.key,
    required this.sections,
    required this.currentSection,
    required this.onSectionSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64, maxHeight: 80),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            children: sections.map((s) {
              final selected = s == currentSection;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => onSectionSwitch(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _iconFor(s),
                          size: 20,
                          color: selected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        if (selected) ...[
                          const SizedBox(width: 8),

                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _labelFor(s),
                                maxLines: 1,
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(MediaPickerSection s) {
    switch (s) {
      case MediaPickerSection.media:
        return Icons.photo_library;
      case MediaPickerSection.audio:
        return Icons.music_note;
      case MediaPickerSection.downloads:
        return Icons.download;
      case MediaPickerSection.documents:
        return Icons.folder;
      case MediaPickerSection.others:
        return Icons.insert_drive_file;
    }
  }

  String _labelFor(MediaPickerSection s) {
    switch (s) {
      case MediaPickerSection.media:
        return 'Медиа';
      case MediaPickerSection.audio:
        return 'Музыка';
      case MediaPickerSection.downloads:
        return 'Download';
      case MediaPickerSection.documents:
        return 'Documents';
      case MediaPickerSection.others:
        return 'Прочие';
    }
  }
}

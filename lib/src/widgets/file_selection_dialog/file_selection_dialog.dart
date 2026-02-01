import 'package:flutter/material.dart';
import 'package:media_ui_package/generated/l10n.dart';
import 'package:media_ui_package/media_ui_package.dart';

class FileSelectionDialog extends StatelessWidget {
  final List<MediaItem> selectedFiles;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback? onClearAll;
  final ValueChanged<MediaItem>? onItemRemoved;
  final bool showConfirmButton;

  const FileSelectionDialog({
    super.key,
    required this.selectedFiles,
    required this.onConfirm,
    required this.onCancel,
    this.onClearAll,
    this.onItemRemoved,
    this.showConfirmButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 500,
          maxWidth: 500,
          minWidth: 300,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.checklist_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${S.of(context).selectedFiles} (${selectedFiles.length})',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),

            Expanded(
              child: selectedFiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(S.of(context).noFilesSelected),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: selectedFiles.length,
                      itemBuilder: (context, index) {
                        final file = selectedFiles[index];
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              file.type == 'video'
                                  ? Icons.videocam
                                  : Icons.photo,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          title: Text(
                            file.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            '${(file.size / 1024).toStringAsFixed(1)} KB • ${file.type}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: onItemRemoved != null
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => onItemRemoved!(file),
                                  iconSize: 20,
                                )
                              : null,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FullscreenMediaView(
                                  mediaItems: selectedFiles,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),

            const Divider(height: 0),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (selectedFiles.isNotEmpty && onClearAll != null)
                    TextButton(
                      onPressed: onClearAll,
                      child: Text(S.of(context).clearAll),
                    ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onCancel,
                    child: Text(S.of(context).cancel),
                  ),
                  if (showConfirmButton && selectedFiles.isNotEmpty)
                    ElevatedButton(
                      onPressed: onConfirm,
                      child: Text(S.of(context).confirm),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

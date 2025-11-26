import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';

class MediaPickerBottomSheet extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final Function(List<MediaItem>)? onSelectionChanged;
  final Function(List<MediaItem>)? onConfirmed;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool showSelectionIndicators;
  final MediaPickerConfig? config;

  const MediaPickerBottomSheet({
    super.key,
    this.showSelectionIndicators = true,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    this.onSelectionChanged,
    this.onConfirmed,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.4,
    this.maxChildSize = 0.9,
    this.config,
  });

  @override
  State<MediaPickerBottomSheet> createState() => _MediaPickerBottomSheetState();
}

class _MediaPickerBottomSheetState extends State<MediaPickerBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final config = widget.config ?? const MediaPickerConfig();
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
      child: MediaPickerConfigScope(
        config: config,
        child: Builder(
          builder: (context) {
            return DraggableScrollableSheet(
              initialChildSize: widget.initialChildSize,
              minChildSize: widget.minChildSize,
              maxChildSize: widget.maxChildSize,
              expand: false,
              builder: (context, scrollController) => Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withAlpha(30),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    _buildHeader(context),
                    const Divider(height: 1),
                    Expanded(child: const MediaGrid()),
                    _buildFooter(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<MediaGridCubit>();
    return BlocBuilder<MediaGridCubit, MediaGridState>(
      builder: (context, state) {
        final selectedCount = state.when(
          initial: () => 0,
          loading: () => 0,
          permissionRequesting: () => 0,
          permissionDenied: () => 0,
          loaded: (_, __, ___, ____, _____, ______, selected) =>
              selected.length,
          error: (_) => 0,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Media',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.allowMultiple
                          ? 'Select up to ${widget.maxSelection} items'
                          : 'Select one item',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withAlpha(60),
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedCount > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$selectedCount',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: cubit.clearSelection,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cubit = context.read<MediaGridCubit>();

    return BlocBuilder<MediaGridCubit, MediaGridState>(
      builder: (context, state) {
        final selectedCount = state.when(
          initial: () => 0,
          loading: () => 0,
          permissionRequesting: () => 0,
          permissionDenied: () => 0,
          loaded: (_, __, ___, ____, _____, ______, selected) =>
              selected.length,
          error: (_) => 0,
        );
        final hasSelection = selectedCount > 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: colorScheme.outline.withAlpha(30)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: hasSelection
                      ? () => Navigator.of(context).pop(cubit.selectedItems)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasSelection
                        ? colorScheme.primary
                        : colorScheme.primary.withAlpha(40),
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (selectedCount > 0 && widget.allowMultiple)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$selectedCount',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Text(
                        widget.allowMultiple ? 'Confirm' : 'Select',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

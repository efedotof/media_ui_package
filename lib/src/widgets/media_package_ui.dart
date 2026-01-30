import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_ui_package/generated/l10n.dart';
import 'package:media_ui_package/media_ui_package.dart';
import 'package:media_ui_package/src/models/media_type.dart';
import 'package:media_ui_package/src/models/upload_media_request.dart';

/// Адаптивный медиа-пикер, который автоматически определяет платформу
/// и использует соответствующую реализацию (диалог для веб/десктопа,
/// bottom sheet для мобильных устройств)
class MediaPackageUI extends StatefulWidget {
  /// Начальный выбор медиа
  final List<MediaItem> initialSelection;

  /// Максимальное количество выбираемых файлов
  final int maxSelection;

  /// Разрешить выбор нескольких файлов
  final bool allowMultiple;

  /// Показывать видео
  final bool showVideos;

  /// Конфигурация пикера
  final MediaPickerConfig config;

  /// Библиотека медиа устройства
  final DeviceMediaLibrary mediaLibrary;

  /// Колбэк при изменении выбора
  final void Function(List<MediaItem>)? onSelectionChanged;

  /// Колбэк при подтверждении с запросами на загрузку
  final void Function(List<UploadMediaRequest>)? onConfirmedWithRequests;

  /// Размер дочернего виджета для bottom sheet
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  /// Показывать индикаторы выбора
  final bool showSelectionIndicators;

  /// Виджет, который будет обернут пикером (для интеграции в UI)
  final Widget? child;

  /// Текст кнопки выбора файлов
  final String? buttonText;

  /// Показывать кнопку для открытия пикера
  final bool showPickButton;

  /// Стиль кнопки
  final ButtonStyle? buttonStyle;

  /// Иконка кнопки
  final Widget? buttonIcon;

  const MediaPackageUI({
    super.key,
    this.initialSelection = const [],
    this.maxSelection = 10,
    this.allowMultiple = true,
    this.showVideos = true,
    required this.config,
    required this.mediaLibrary,
    this.onSelectionChanged,
    this.onConfirmedWithRequests,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.4,
    this.maxChildSize = 0.9,
    this.showSelectionIndicators = true,
    this.child,
    this.buttonText,
    this.showPickButton = true,
    this.buttonStyle,
    this.buttonIcon,
  });

  /// Статический метод для открытия медиа-пикера
  static Future<List<UploadMediaRequest>?> open({
    required BuildContext context,
    List<MediaItem> initialSelection = const [],
    int maxSelection = 10,
    bool allowMultiple = true,
    bool showVideos = true,
    double initialChildSize = 0.7,
    double minChildSize = 0.4,
    double maxChildSize = 0.9,
    bool showSelectionIndicators = true,
    MediaPickerConfig? config,
    DeviceMediaLibrary? mediaLibrary,
    void Function(List<MediaItem>)? onSelectionChanged,
    void Function(List<UploadMediaRequest>)? onConfirmedWithRequests,
  }) async {
    final isWeb = kIsWeb;
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    final actualMediaLibrary = mediaLibrary ?? DeviceMediaLibrary();
    final actualConfig = config ?? const MediaPickerConfig();

    // Для веба и десктопа используем диалог
    if (isWeb || isDesktop) {
      return await _openMediaPickerDialog(
        context: context,
        initialSelection: initialSelection,
        maxSelection: maxSelection,
        allowMultiple: allowMultiple,
        showVideos: showVideos,
        showSelectionIndicators: showSelectionIndicators,
        config: actualConfig,
        mediaLibrary: actualMediaLibrary,
        onSelectionChanged: onSelectionChanged,
        onConfirmedWithRequests: onConfirmedWithRequests,
      );
    }

    // Для мобильных устройств используем bottom sheet
    return await _openMediaPickerBottomSheet(
      context: context,
      initialSelection: initialSelection,
      maxSelection: maxSelection,
      allowMultiple: allowMultiple,
      showVideos: showVideos,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      showSelectionIndicators: showSelectionIndicators,
      config: actualConfig,
      mediaLibrary: actualMediaLibrary,
      onSelectionChanged: onSelectionChanged,
      onConfirmedWithRequests: onConfirmedWithRequests,
    );
  }

  static Future<List<UploadMediaRequest>?> _openMediaPickerDialog({
    required BuildContext context,
    required List<MediaItem> initialSelection,
    required int maxSelection,
    required bool allowMultiple,
    required bool showVideos,
    required bool showSelectionIndicators,
    required MediaPickerConfig config,
    required DeviceMediaLibrary mediaLibrary,
    void Function(List<MediaItem>)? onSelectionChanged,
    void Function(List<UploadMediaRequest>)? onConfirmedWithRequests,
  }) async {
    return showDialog<List<UploadMediaRequest>>(
      context: context,
      builder: (_) => _AdaptiveMediaPickerDialog(
        initialSelection: initialSelection,
        maxSelection: maxSelection,
        allowMultiple: allowMultiple,
        showVideos: showVideos,
        showSelectionIndicators: showSelectionIndicators,
        config: config,
        mediaLibrary: mediaLibrary,
        onSelectionChanged: onSelectionChanged,
        onConfirmedWithRequests: onConfirmedWithRequests,
      ),
    );
  }

  static Future<List<UploadMediaRequest>?> _openMediaPickerBottomSheet({
    required BuildContext context,
    required List<MediaItem> initialSelection,
    required int maxSelection,
    required bool allowMultiple,
    required bool showVideos,
    required double initialChildSize,
    required double minChildSize,
    required double maxChildSize,
    required bool showSelectionIndicators,
    required MediaPickerConfig config,
    required DeviceMediaLibrary mediaLibrary,
    void Function(List<MediaItem>)? onSelectionChanged,
    void Function(List<UploadMediaRequest>)? onConfirmedWithRequests,
  }) async {
    final result = await showModalBottomSheet<List<MediaItem>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: _AdaptiveMediaPickerScreen(
              initialSelection: initialSelection,
              maxSelection: maxSelection,
              allowMultiple: allowMultiple,
              showVideos: showVideos,
              showDragHandle: true,
              showCancelButton: true,
              showSelectionIndicators: showSelectionIndicators,
              config: config,
              mediaLibrary: mediaLibrary,
              onSelectionChanged: onSelectionChanged,
              onConfirmed: (selectedItems) async {
                final utilsMedia = UtilsMedia();
                final requests = <UploadMediaRequest>[];
                for (final item in selectedItems) {
                  final request = await utilsMedia.createUploadRequest(item);
                  if (request != null) {
                    requests.add(request);
                  }
                }
                if (context.mounted) {
                  Navigator.of(context).pop(requests);
                }
              },
            ),
          );
        },
      ),
    );

    if (result != null && onConfirmedWithRequests != null) {
      final utilsMedia = UtilsMedia();
      final requests = <UploadMediaRequest>[];
      for (final item in result) {
        final request = await utilsMedia.createUploadRequest(item);
        if (request != null) {
          requests.add(request);
        }
      }
      onConfirmedWithRequests(requests);
    }
    return null;
  }

  @override
  State<MediaPackageUI> createState() => _MediaPackageUIState();
}

class _MediaPackageUIState extends State<MediaPackageUI> {
  Future<void> _openPicker() async {
    final result = await MediaPackageUI.open(
      context: context,
      initialSelection: widget.initialSelection,
      maxSelection: widget.maxSelection,
      allowMultiple: widget.allowMultiple,
      showVideos: widget.showVideos,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      showSelectionIndicators: widget.showSelectionIndicators,
      config: widget.config,
      mediaLibrary: widget.mediaLibrary,
      onSelectionChanged: widget.onSelectionChanged,
      onConfirmedWithRequests: widget.onConfirmedWithRequests,
    );

    if (result != null && widget.onConfirmedWithRequests != null) {
      widget.onConfirmedWithRequests!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Если передан дочерний виджет, оборачиваем его в GestureDetector
    if (widget.child != null) {
      return GestureDetector(onTap: _openPicker, child: widget.child);
    }

    // Иначе показываем кнопку
    return ElevatedButton.icon(
      onPressed: _openPicker,
      style: widget.buttonStyle,
      icon: widget.buttonIcon ?? const Icon(Icons.photo_library),
      label: Text(widget.buttonText ?? S.of(context).chooseFiles),
    );
  }
}

// Внутренний диалог для веб/десктоп платформ
class _AdaptiveMediaPickerDialog extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final bool showSelectionIndicators;
  final MediaPickerConfig config;
  final DeviceMediaLibrary mediaLibrary;
  final void Function(List<MediaItem>)? onSelectionChanged;
  final void Function(List<UploadMediaRequest>)? onConfirmedWithRequests;

  const _AdaptiveMediaPickerDialog({
    required this.initialSelection,
    required this.maxSelection,
    required this.allowMultiple,
    required this.showVideos,
    required this.showSelectionIndicators,
    required this.config,
    required this.mediaLibrary,
    this.onSelectionChanged,
    this.onConfirmedWithRequests,
  });

  @override
  State<_AdaptiveMediaPickerDialog> createState() =>
      __AdaptiveMediaPickerDialogState();
}

class __AdaptiveMediaPickerDialogState
    extends State<_AdaptiveMediaPickerDialog> {
  late MediaGridCubit _mediaGridCubit;
  final UtilsMedia _utilsMedia = UtilsMedia();

  @override
  void initState() {
    super.initState();

    final mediaType = widget.showVideos ? MediaType.all : MediaType.images;
    _mediaGridCubit = MediaGridCubit(
      mediaType: mediaType,
      albumId: null,
      thumbnailBuilder: null,
      allowMultiple: widget.allowMultiple,
      maxSelection: widget.maxSelection,
      initialSelection: widget.initialSelection,
    )..init();
  }

  @override
  void dispose() {
    _mediaGridCubit.close();
    super.dispose();
  }

  Future<List<UploadMediaRequest>> _getUploadRequests(
    List<MediaItem> items,
  ) async {
    final result = <UploadMediaRequest>[];

    for (final item in items) {
      try {
        final request = await _utilsMedia.createUploadRequest(item);
        if (request != null) {
          result.add(request);
        }
      } catch (e) {
        debugPrint('Error creating upload request for ${item.uri}: $e');
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mediaGridCubit,
      child: BlocListener<MediaGridCubit, MediaGridState>(
        listener: (context, state) {
          state.whenOrNull(
            loaded:
                (
                  mediaItems,
                  thumbnailCache,
                  hasMoreItems,
                  currentOffset,
                  isLoadingMore,
                  showSelectionIndicators,
                  selectedMediaItems,
                ) {
                  widget.onSelectionChanged?.call(selectedMediaItems);
                },
          );
        },
        child: MediaPickerConfigScope(
          config: widget.config,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.config.borderRadius),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: Text(S.of(context).selectMedia),
                    automaticallyImplyLeading: false,
                    actions: [
                      BlocBuilder<MediaGridCubit, MediaGridState>(
                        builder: (context, state) {
                          final cubit = context.read<MediaGridCubit>();
                          final selected = cubit.selectedItems;

                          return TextButton(
                            onPressed: selected.isEmpty
                                ? null
                                : () async {
                                    final requests = await _getUploadRequests(
                                      selected,
                                    );
                                    if (context.mounted) {
                                      Navigator.of(context).pop(selected);
                                      widget.onConfirmedWithRequests?.call(
                                        requests,
                                      );
                                    }
                                  },
                            child: Text(S.of(context).confirm),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: MediaGrid(autoPlayVideosInFullscreen: true)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BlocBuilder<MediaGridCubit, MediaGridState>(
                      builder: (context, state) {
                        final cubit = context.read<MediaGridCubit>();
                        final selected = cubit.selectedItems;

                        if (selected.isEmpty) {
                          return const SizedBox();
                        }

                        return Row(
                          children: [
                            Text(
                              '${selected.length}/${widget.maxSelection} ${S.of(context).selected}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                cubit.clearSelection();
                              },
                              child: Text(S.of(context).clearEverything),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Внутренний экран для мобильных платформ
class _AdaptiveMediaPickerScreen extends StatefulWidget {
  final List<MediaItem> initialSelection;
  final int maxSelection;
  final bool allowMultiple;
  final bool showVideos;
  final bool showDragHandle;
  final bool showCancelButton;
  final bool showSelectionIndicators;
  final MediaPickerConfig config;
  final DeviceMediaLibrary mediaLibrary;
  final void Function(List<MediaItem>)? onSelectionChanged;
  final void Function(List<MediaItem>)? onConfirmed;

  const _AdaptiveMediaPickerScreen({
    required this.initialSelection,
    required this.maxSelection,
    required this.allowMultiple,
    required this.showVideos,
    this.showDragHandle = false,
    this.showCancelButton = true,
    required this.showSelectionIndicators,
    required this.config,
    required this.mediaLibrary,
    this.onSelectionChanged,
    required this.onConfirmed,
  });

  @override
  State<_AdaptiveMediaPickerScreen> createState() =>
      __AdaptiveMediaPickerScreenState();
}

class __AdaptiveMediaPickerScreenState
    extends State<_AdaptiveMediaPickerScreen> {
  late List<MediaItem> selectedItems;

  @override
  void initState() {
    super.initState();
    selectedItems = [...widget.initialSelection];
  }

  @override
  Widget build(BuildContext context) {
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
      child: MediaPickerConfigScope(
        config: widget.config,
        child: Builder(
          builder: (context) {
            return BlocListener<MediaGridCubit, MediaGridState>(
              listener: (context, state) {
                state.whenOrNull(
                  loaded:
                      (
                        mediaItems,
                        thumbnailCache,
                        hasMoreItems,
                        currentOffset,
                        isLoadingMore,
                        showSelectionIndicators,
                        selectedMediaItems,
                      ) {
                        widget.onSelectionChanged?.call(selectedMediaItems);
                      },
                );
              },
              child: Column(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S.of(context).selectMedia,
                          style: theme.textTheme.titleLarge,
                        ),
                        if (widget.showCancelButton)
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                            color: colorScheme.onSurface,
                            tooltip: S.of(context).cancel,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: MediaGrid(autoPlayVideosInFullscreen: true)),
                  BlocBuilder<MediaGridCubit, MediaGridState>(
                    builder: (context, state) {
                      final cubit = context.read<MediaGridCubit>();
                      final selected = cubit.selectedItems;
                      final hasSelection = selected.isNotEmpty;

                      return SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                          child: Row(
                            children: [
                              if (selected.isNotEmpty)
                                Text(
                                  '${selected.length}/${widget.maxSelection}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              const Spacer(),
                              OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(S.of(context).cancel),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: hasSelection
                                    ? () async {
                                        if (context.mounted) {
                                          Navigator.of(context).pop(selected);
                                          widget.onConfirmed?.call(selected);
                                        }
                                      }
                                    : null,
                                child: Text(S.of(context).confirm),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Упрощенная версия адаптивного пикера для быстрой интеграции
class SimpleAdaptiveMediaPicker extends StatelessWidget {
  final Widget child;
  final Function(List<UploadMediaRequest>)? onFilesSelected;
  final MediaPickerConfig? config;
  final bool showVideos;
  final bool allowMultiple;
  final int maxSelection;

  const SimpleAdaptiveMediaPicker({
    super.key,
    required this.child,
    this.onFilesSelected,
    this.config,
    this.showVideos = true,
    this.allowMultiple = true,
    this.maxSelection = 10,
  });

  @override
  Widget build(BuildContext context) {
    return MediaPackageUI(
      config: config ?? const MediaPickerConfig(),
      mediaLibrary: DeviceMediaLibrary(),
      showVideos: showVideos,
      allowMultiple: allowMultiple,
      maxSelection: maxSelection,
      onConfirmedWithRequests: onFilesSelected,
      child: child,
    );
  }
}

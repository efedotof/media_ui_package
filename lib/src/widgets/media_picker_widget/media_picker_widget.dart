import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:device_media_library/device_media_library.dart';
import 'package:media_ui_package/src/models/models.dart';
import 'package:media_ui_package/src/themes/media_picker_theme.dart';
import 'package:media_ui_package/src/widgets/media_picker_ui/media_picker_ui.dart';
import 'package:media_ui_package/src/widgets/selection_app_bar/selection_app_bar.dart';

import 'build_recursive_switch.dart';
import 'build_permission_banner.dart';
import 'build_bottom_menu.dart';

enum MediaPickerSection { media, audio, downloads, documents, others }

class MediaPickerWidget extends StatefulWidget {
  final List<MediaPickerSection> sections;
  final MediaPickerSection initialSection;
  final bool multiSelect;
  final String title;
  final String confirmLabel;
  final int thumbnailSize;
  final bool recursive;
  final MediaPickerConfig? config;
  final ValueChanged<MediaPickerResult>? onConfirm;
  final VoidCallback? onCancel;

  const MediaPickerWidget({
    super.key,
    this.sections = const [
      MediaPickerSection.media,
      MediaPickerSection.audio,
      MediaPickerSection.downloads,
      MediaPickerSection.documents,
      MediaPickerSection.others,
    ],
    this.initialSection = MediaPickerSection.media,
    this.multiSelect = true,
    this.title = 'Выбрать медиа',
    this.confirmLabel = 'Готово',
    this.thumbnailSize = 200,
    this.recursive = false,
    this.config,
    this.onConfirm,
    this.onCancel,
  });

  @override
  MediaPickerWidgetState createState() => MediaPickerWidgetState();
}

class MediaPickerWidgetState extends State<MediaPickerWidget>
    with WidgetsBindingObserver {
  final DeviceMediaLibrary _lib = DeviceMediaLibrary();

  late MediaPickerSection _section = widget.initialSection;
  final Map<MediaPickerSection, MediaPickerController> _controllers = {};

  MediaPermissionState _permissions = const MediaPermissionState();
  StorageAccessInfo? _downloadsAccess;
  StorageAccessInfo? _documentsAccess;
  bool _booting = true;

  late bool _recursive = widget.recursive;

  final ScrollController _scrollController = ScrollController();
  bool _isBottomMenuVisible = true;

  MediaPickerConfig get _config =>
      widget.config ?? MediaPickerConfig.of(context);

  MediaPickerResult get currentResult {
    final all = <SelectedMediaItem>[];
    final seenUris = <String>{};
    for (final controller in _controllers.values) {
      for (final item in controller.selected) {
        if (seenUris.add(item.uri)) {
          all.add(item);
        }
      }
    }
    return MediaPickerResult.fromItems(all);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _bootstrap();
  }

  @override
  void didUpdateWidget(covariant MediaPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recursive != widget.recursive) {
      _recursive = widget.recursive;
      _rebuildFolderSections();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      if (_isBottomMenuVisible) setState(() => _isBottomMenuVisible = false);
    } else if (direction == ScrollDirection.forward) {
      if (!_isBottomMenuVisible) setState(() => _isBottomMenuVisible = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAllFilesPermission();
    }
  }

  Future<void> _bootstrap() async {
    setState(() => _permissions = _permissions.copyWith(isLoading: true));

    bool scoped = false;
    bool allFiles = false;

    try {
      scoped = await _lib.checkPermission();
      if (!scoped) scoped = await _lib.requestPermission();
      allFiles = await _lib.checkAllFilesPermission();
    } on PlatformException catch (e) {
      debugPrint('Permission error: ${e.code} ${e.message}');
    }

    await _refreshStorageAccess();

    if (!mounted) return;
    setState(() {
      _permissions = MediaPermissionState.fromBools(
        scopedGranted: scoped,
        allFilesGranted: allFiles,
      );
      _booting = false;
    });

    if (scoped) await _ensureController(_section).loadInitial();
  }

  Future<void> _refreshAllFilesPermission() async {
    try {
      final granted = await _lib.checkAllFilesPermission();
      if (!mounted) return;
      setState(() {
        _permissions = _permissions.copyWith(
          allFiles: granted
              ? MediaPermissionStatus.granted
              : MediaPermissionStatus.denied,
        );
      });
      if (granted &&
          (_section == MediaPickerSection.downloads ||
              _section == MediaPickerSection.documents)) {
        await _refreshStorageAccess();
        await _reloadCurrentSection();
      }
    } catch (e) {
      debugPrint('refreshAllFilesPermission: $e');
    }
  }

  Future<void> _refreshStorageAccess() async {
    StorageAccessInfo? d;
    StorageAccessInfo? doc;
    try {
      d = StorageAccessInfo.fromMap(
        await _lib.checkStorageAccess(folder: 'download'),
      );
    } catch (e) {
      d = StorageAccessInfo.unsupported(e.toString());
    }
    try {
      doc = StorageAccessInfo.fromMap(
        await _lib.checkStorageAccess(folder: 'document'),
      );
    } catch (e) {
      doc = StorageAccessInfo.unsupported(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _downloadsAccess = d;
      _documentsAccess = doc;
    });
  }

  MediaPickerController _ensureController(MediaPickerSection section) {
    return _controllers.putIfAbsent(section, () {
      switch (section) {
        case MediaPickerSection.media:
          return MediaPickerController(
            source: MediaSource.device,
            mediaFilter: MediaFilter.all,
            multiSelect: widget.multiSelect,
          );
        case MediaPickerSection.audio:
          return MediaPickerController(
            source: MediaSource.device,
            mediaFilter: MediaFilter.audio,
            multiSelect: widget.multiSelect,
          );
        case MediaPickerSection.downloads:
          return MediaPickerController(
            source: MediaSource.downloads,
            mediaFilter: MediaFilter.all,
            multiSelect: widget.multiSelect,
            recursive: _recursive,
          );
        case MediaPickerSection.documents:
          return MediaPickerController(
            source: MediaSource.documents,
            mediaFilter: MediaFilter.all,
            multiSelect: widget.multiSelect,
            recursive: _recursive,
          );
        case MediaPickerSection.others:
          return MediaPickerController(
            source: MediaSource.picked,
            mediaFilter: MediaFilter.all,
            multiSelect: widget.multiSelect,
          );
      }
    });
  }

  MediaPickerController get _currentController => _ensureController(_section);

  Future<void> _reloadCurrentSection() async {
    await _currentController.refresh();
  }

  Future<void> _switchSection(MediaPickerSection section) async {
    if (section == MediaPickerSection.others) {
      await _openSystemExplorer();
      return;
    }

    setState(() => _section = section);
    final c = _ensureController(section);
    if (c.items.isEmpty && !c.isLoading) {
      await c.loadInitial();
    }
  }

  Future<void> _openSystemExplorer() async {
    try {
      final picked = await _lib.pickFiles(
        multiple: widget.multiSelect,
        allowedFileTypes: ['*'],
      );

      if (picked != null && picked.isNotEmpty && mounted) {
        final items = picked.map((e) => MediaItem.fromMap(e)).toList();
        final controller = _ensureController(MediaPickerSection.others);

        controller.addItems(items);

        for (final item in items) {
          controller.select(item);
        }

        setState(() => _section = MediaPickerSection.others);
      }
    } catch (e) {
      _snack('Ошибка выбора файлов: $e');
    }
  }

  void _disposeController(MediaPickerSection section) {
    final c = _controllers.remove(section);
    c?.dispose();
  }

  void _rebuildFolderSections() {
    _disposeController(MediaPickerSection.downloads);
    _disposeController(MediaPickerSection.documents);
    if (_isFolderSection) {
      _ensureController(_section).loadInitial();
    }
  }

  Future<void> _onRecursiveChanged(bool value) async {
    setState(() => _recursive = value);
    final target = _section;
    _disposeController(MediaPickerSection.downloads);
    _disposeController(MediaPickerSection.documents);
    if (target == MediaPickerSection.downloads ||
        target == MediaPickerSection.documents) {
      await _ensureController(target).loadInitial();
    }
  }

  void _onConfirm() {
    final result = currentResult;
    if (result.isEmpty) return;
    widget.onConfirm?.call(result);
  }

  void _onCancel() {
    widget.onCancel?.call();
  }

  Future<void> _requestAllFilesAccess() async {
    try {
      await _lib.requestAllFilesPermission();
    } catch (e) {
      debugPrint('requestAllFilesPermission: $e');
    }
  }

  Future<void> _requestDownloadsFolderAccess() async {
    try {
      await _lib.requestDownloadsFolderAccess();
      await _refreshStorageAccess();
      await _reloadCurrentSection();
    } on PlatformException catch (e) {
      _snack('Не удалось открыть проводник: ${e.message}');
    }
  }

  Future<void> _requestDocumentsFolderAccess() async {
    try {
      await _lib.requestDocumentsFolderAccess();
      await _refreshStorageAccess();
      await _reloadCurrentSection();
    } on PlatformException catch (e) {
      _snack('Не удалось открыть проводник: ${e.message}');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  bool get _isFolderSection =>
      _section == MediaPickerSection.downloads ||
      _section == MediaPickerSection.documents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = _currentController;

    return MediaPickerConfigScope(
      config: _config,
      child: Material(
        color: theme.colorScheme.surface,
        child: Stack(
          children: [
            Column(
              children: [
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    return SelectionAppBar(
                      title: widget.title,
                      selectedCount: controller.selected.length,
                      totalCount: controller.items.length,
                      multiSelect: widget.multiSelect,
                      confirmLabel: widget.confirmLabel,
                      onClose: _onCancel,
                      onSelectAll: controller.selectAll,
                      onDeselectAll: controller.clearSelection,
                      onConfirm: _onConfirm,
                    );
                  },
                ),

                if (!_booting)
                  BuildPermissionBanner(
                    permissions: _permissions,
                    currentSection: _section,
                    downloadsAccess: _downloadsAccess,
                    documentsAccess: _documentsAccess,
                    onBootstrap: _bootstrap,
                    onRequestDownloadsFolderAccess:
                        _requestDownloadsFolderAccess,
                    onRequestDocumentsFolderAccess:
                        _requestDocumentsFolderAccess,
                    onRequestAllFilesAccess: _requestAllFilesAccess,
                  ),

                if (_isFolderSection)
                  BuildRecursiveSwitch(
                    value: _recursive,
                    onChanged: _onRecursiveChanged,
                  ),

                Expanded(
                  child: _booting
                      ? const Center(child: CircularProgressIndicator())
                      : AnimatedBuilder(
                          animation: controller,
                          builder: (context, _) {
                            return MediaPickerUi(
                              controller: controller,
                              thumbnailSize: widget.thumbnailSize,
                              scrollController: _scrollController,
                            );
                          },
                        ),
                ),
              ],
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              bottom: _isBottomMenuVisible
                  ? 24 + MediaQuery.paddingOf(context).bottom
                  : -100,
              left: 16,
              right: 16,
              child: BuildBottomMenu(
                sections: widget.sections,
                currentSection: _section,
                onSectionSwitch: _switchSection,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:media_ui_package/src/models/media_filter.dart';
import 'package:media_ui_package/src/models/media_item.dart';
import 'package:media_ui_package/src/models/media_picker_controller.dart';
import 'package:media_ui_package/src/models/media_source.dart';

import 'build_audio_list.dart';
import 'build_file_list.dart';
import 'build_grid_media_picker_ui.dart';
import 'empty_view.dart';
import 'error_view.dart';

class MediaPickerUi extends StatelessWidget {
  final MediaPickerController controller;
  final ValueChanged<MediaItem>? onItemTap;
  final ScrollController? scrollController;
  final int thumbnailSize;
  final bool showLoadMore;
  final double autoLoadThreshold;
  final int inlineImageMaxBytes;

  const MediaPickerUi({
    super.key,
    required this.controller,
    this.onItemTap,
    this.scrollController,
    this.thumbnailSize = 200,
    this.showLoadMore = true,
    this.autoLoadThreshold = 400,
    this.inlineImageMaxBytes = 512 * 1024,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final err = controller.error;
        if (err != null && controller.items.isEmpty) {
          return ErrorView(
            message: _getFriendlyErrorMessage(err),
            onRetry: controller.loadInitial,
          );
        }

        if (controller.items.isEmpty) {
          return EmptyView(source: controller.source);
        }

        final isAudioTab =
            controller.source == MediaSource.device &&
            controller.mediaFilter == MediaFilter.audio;

        final isMediaTab =
            controller.source == MediaSource.device &&
            controller.mediaFilter != MediaFilter.audio;

        if (isMediaTab) {
          return BuildGridMediaPickerUi(
            items: controller.items,
            controller: controller,
            scrollController: scrollController,
            showLoadMore: showLoadMore,
            autoLoadThreshold: autoLoadThreshold,
            thumbnailSize: thumbnailSize,
            onItemTap: onItemTap,
          );
        }

        if (isAudioTab) {
          return BuildAudioList(
            items: controller.items,
            controller: controller,
            scrollController: scrollController,
            showLoadMore: showLoadMore,
            autoLoadThreshold: autoLoadThreshold,
            onItemTap: onItemTap,
          );
        }

        return BuildFileList(
          items: controller.items,
          controller: controller,
          scrollController: scrollController,
          showLoadMore: showLoadMore,
          autoLoadThreshold: autoLoadThreshold,
          inlineImageMaxBytes: inlineImageMaxBytes,
          onItemTap: onItemTap,
        );
      },
    );
  }

  String _getFriendlyErrorMessage(dynamic err) {
    final code = err.code?.toString() ?? '';
    final source = controller.source == MediaSource.downloads
        ? 'Download'
        : 'Documents';

    switch (code) {
      case 'SAF_REQUIRED':
        return 'Нет доступа к папке $source.\n\n'
            'Нажмите «Выбрать» в баннере выше, чтобы указать папку в проводнике.';
      case 'PERMISSION_REQUIRED':
        return 'Нет доступа к файлам.\n\n'
            'Предоставьте приложению полный доступ к файлам в настройках устройства.';
      case 'PERMISSION_DENIED':
        return 'Доступ запрещен.\n\n'
            'Разрешите приложению чтение файлов в настройках.';
      default:
        return err.message ?? 'Произошла ошибка при загрузке файлов ($code)';
    }
  }
}

import 'package:flutter/material.dart';
import 'banner.dart';
import '../../models/storage_access_info.dart';

class BuildFolderBanner extends StatelessWidget {
  final StorageAccessInfo? info;
  final String folderName;
  final Future<void> Function() onPick;
  final Future<void> Function() onRequestAllFilesAccess;

  const BuildFolderBanner({
    super.key,
    required this.info,
    required this.folderName,
    required this.onPick,
    required this.onRequestAllFilesAccess,
  });

  @override
  Widget build(BuildContext context) {
    if (info == null) return const SizedBox.shrink();

    if (!info!.supported) {
      return MediaPickerBanner(
        color: Colors.grey.shade200,
        icon: Icons.block,
        iconColor: Colors.grey,
        text: info!.reason.isNotEmpty
            ? info!.reason
            : 'Доступ к этой папке не поддерживается',
      );
    }

    if (info!.hasAccess) return const SizedBox.shrink();

    if (info!.needsSafPicker) {
      return MediaPickerBanner(
        color: Colors.blue.shade50,
        icon: Icons.folder_open,
        iconColor: Colors.blue,
        text: 'Выберите папку $folderName в проводнике. '
            'Это нужно сделать один раз.',
        actionLabel: 'Выбрать',
        onAction: onPick,
      );
    }

    if (info!.needsManageSettings) {
      return MediaPickerBanner(
        color: Colors.red.shade50,
        icon: Icons.lock_outline,
        iconColor: Colors.red,
        text: 'Для доступа к $folderName нужен полный доступ к файлам',
        actionLabel: 'Настройки',
        onAction: onRequestAllFilesAccess,
      );
    }

    return const SizedBox.shrink();
  }
}
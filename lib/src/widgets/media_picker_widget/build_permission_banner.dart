import 'package:flutter/material.dart';
import 'banner.dart';
import 'build_folder_banner.dart';
import '../../models/media_permission_state.dart';
import '../../models/storage_access_info.dart';
import 'media_picker_widget.dart'; 

class BuildPermissionBanner extends StatelessWidget {
  final MediaPermissionState permissions;
  final MediaPickerSection currentSection;
  final StorageAccessInfo? downloadsAccess;
  final StorageAccessInfo? documentsAccess;
  final Future<void> Function() onBootstrap;
  final Future<void> Function() onRequestDownloadsFolderAccess;
  final Future<void> Function() onRequestDocumentsFolderAccess;
  final Future<void> Function() onRequestAllFilesAccess;

  const BuildPermissionBanner({
    super.key,
    required this.permissions,
    required this.currentSection,
    required this.downloadsAccess,
    required this.documentsAccess,
    required this.onBootstrap,
    required this.onRequestDownloadsFolderAccess,
    required this.onRequestDocumentsFolderAccess,
    required this.onRequestAllFilesAccess,
  });

  @override
  Widget build(BuildContext context) {
    if (!permissions.hasScopedPermission) {
      return MediaPickerBanner(
        color: Colors.orange.shade100,
        icon: Icons.warning_amber,
        iconColor: Colors.orange,
        text: 'Нужны разрешения на чтение медиа',
        actionLabel: 'Выдать',
        onAction: onBootstrap,
      );
    }

    if (currentSection == MediaPickerSection.downloads) {
      return BuildFolderBanner(
        info: downloadsAccess,
        folderName: 'Download',
        onPick: onRequestDownloadsFolderAccess,
        onRequestAllFilesAccess: onRequestAllFilesAccess,
      );
    }
    
    if (currentSection == MediaPickerSection.documents) {
      return BuildFolderBanner(
        info: documentsAccess,
        folderName: 'Documents',
        onPick: onRequestDocumentsFolderAccess,
        onRequestAllFilesAccess: onRequestAllFilesAccess,
      );
    }

    return const SizedBox.shrink();
  }
}
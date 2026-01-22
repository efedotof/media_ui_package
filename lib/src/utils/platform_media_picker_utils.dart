import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_media_library/device_media_library.dart';

class PlatformMediaPickerUtils {
  static final DeviceMediaLibrary _mediaLibrary = DeviceMediaLibrary();

  static bool get isWeb => kIsWeb;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isDesktop =>
      isWindows || (!kIsWeb && (Platform.isMacOS || Platform.isLinux));
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<List<Map<String, dynamic>>?> pickFiles({
    bool multiple = true,
    List<String>? allowedFileTypes,
  }) async {
    return await _mediaLibrary.pickFiles(
      multiple: multiple,
      allowedFileTypes: allowedFileTypes,
    );
  }

  static Future<List<Map<String, dynamic>>> pickFilesFromDrop(
    List<dynamic> files,
  ) async {
    return await _mediaLibrary.pickFilesFromDrop(files);
  }
}

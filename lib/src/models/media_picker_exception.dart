import 'package:flutter/services.dart';

class MediaPickerException implements Exception {
  final String code;
  final String? message;
  final dynamic details;

  const MediaPickerException({required this.code, this.message, this.details});

  factory MediaPickerException.fromPlatform(PlatformException e) {
    return MediaPickerException(
      code: e.code,
      message: e.message,
      details: e.details,
    );
  }

  bool get isPermissionDenied =>
      code == 'PERMISSION_DENIED' || code == 'PERMISSION_REQUIRED';

  bool get isSafRequired => code == 'SAF_REQUIRED';

  bool get isThumbnailError => code == 'THUMBNAIL_ERROR';

  bool get isQueryError => code == 'QUERY_ERROR';

  @override
  String toString() =>
      'MediaPickerException($code${message != null ? ': $message' : ''})';
}

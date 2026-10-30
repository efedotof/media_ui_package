enum MediaPermissionStatus {
  notDetermined,
  granted,
  denied,
  permanentlyDenied;

  bool get isGranted => this == MediaPermissionStatus.granted;
  bool get isDenied =>
      this == MediaPermissionStatus.denied ||
      this == MediaPermissionStatus.permanentlyDenied;
}

class MediaPermissionState {
  final MediaPermissionStatus scoped;
  final MediaPermissionStatus allFiles;
  final bool isLoading;

  const MediaPermissionState({
    this.scoped = MediaPermissionStatus.notDetermined,
    this.allFiles = MediaPermissionStatus.notDetermined,
    this.isLoading = false,
  });

  bool get hasScopedPermission => scoped == MediaPermissionStatus.granted;

  bool get hasAllFilesPermission => allFiles == MediaPermissionStatus.granted;

  bool get canReadMedia => hasScopedPermission;

  bool get canReadAllFiles => hasAllFilesPermission;

  MediaPermissionState copyWith({
    MediaPermissionStatus? scoped,
    MediaPermissionStatus? allFiles,
    bool? isLoading,
  }) {
    return MediaPermissionState(
      scoped: scoped ?? this.scoped,
      allFiles: allFiles ?? this.allFiles,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static MediaPermissionStatus _statusFromBool(bool value) =>
      value ? MediaPermissionStatus.granted : MediaPermissionStatus.denied;

  factory MediaPermissionState.fromBools({
    required bool scopedGranted,
    required bool allFilesGranted,
    bool isLoading = false,
  }) {
    return MediaPermissionState(
      scoped: _statusFromBool(scopedGranted),
      allFiles: _statusFromBool(allFilesGranted),
      isLoading: isLoading,
    );
  }
}

import 'dart:async';

import 'package:device_media_library/device_media_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'models/media_permission_state.dart';
import 'models/storage_access_info.dart';

class MediaUiPackageInitialize with WidgetsBindingObserver {
  MediaUiPackageInitialize._();

  static final MediaUiPackageInitialize _instance =
      MediaUiPackageInitialize._();

  factory MediaUiPackageInitialize() => _instance;

  final ValueNotifier<MediaPermissionState> permissions =
      ValueNotifier<MediaPermissionState>(const MediaPermissionState());

  bool get isInitialized => _pluginInitialized;

  bool get isReady =>
      _pluginInitialized &&
      (_isNonMobile || permissions.value.hasScopedPermission);

  MediaPermissionState get state => permissions.value;

  final DeviceMediaLibrary _lib = DeviceMediaLibrary();

  bool _pluginInitialized = false;
  bool _lifecycleAttached = false;

  Completer<MediaPermissionState>? _bootstrapping;

  bool? _isNonMobileCached;

  bool get _isNonMobile {
    _isNonMobileCached ??=
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
    return _isNonMobileCached!;
  }

  Future<MediaPermissionState> initialize({
    bool requestScopedPermission = true,
    bool checkAllFilesPermission = true,
  }) {
    if (_isNonMobile) {
      if (!_pluginInitialized) {
        DeviceMediaLibrary.initialize();
        _pluginInitialized = true;
      }
      if (!permissions.value.hasScopedPermission ||
          !permissions.value.hasAllFilesPermission) {
        permissions.value = MediaPermissionState.fromBools(
          scopedGranted: true,
          allFilesGranted: true,
        );
      }
      return Future.value(permissions.value);
    }

    if (_pluginInitialized && permissions.value.hasScopedPermission) {
      return Future.value(permissions.value);
    }

    if (_bootstrapping != null) return _bootstrapping!.future;

    _bootstrapping = Completer<MediaPermissionState>();
    _runBootstrap(
      requestScopedPermission: requestScopedPermission,
      checkAllFilesPermission: checkAllFilesPermission,
    );
    return _bootstrapping!.future;
  }

  Future<void> ensureInitialized() async {
    if (_pluginInitialized) return;
    await initialize(
      requestScopedPermission: false,
      checkAllFilesPermission: false,
    );
  }

  Future<void> _runBootstrap({
    required bool requestScopedPermission,
    required bool checkAllFilesPermission,
  }) async {
    final completer = _bootstrapping!;
    try {
      DeviceMediaLibrary.initialize();
      _pluginInitialized = true;

      permissions.value = permissions.value.copyWith(isLoading: true);

      bool scoped = await _lib.checkPermission();
      if (!scoped && requestScopedPermission) {
        scoped = await _lib.requestPermission();
      }

      bool allFiles = false;
      if (checkAllFilesPermission) {
        try {
          allFiles = await _lib.checkAllFilesPermission();
        } catch (e) {
          debugPrint('checkAllFilesPermission error: $e');
        }
      }

      permissions.value = MediaPermissionState.fromBools(
        scopedGranted: scoped,
        allFilesGranted: allFiles,
      );

      _attachLifecycle();
      completer.complete(permissions.value);
    } catch (e, st) {
      permissions.value = permissions.value.copyWith(isLoading: false);
      completer.completeError(e, st);
    } finally {
      _bootstrapping = null;
    }
  }

  Future<MediaPermissionState> refresh() async {
    await ensureInitialized();
    if (_isNonMobile) return permissions.value;

    bool scoped = permissions.value.hasScopedPermission;
    bool allFiles = permissions.value.hasAllFilesPermission;

    try {
      scoped = await _lib.checkPermission();
    } catch (e) {
      debugPrint('checkPermission error: $e');
    }
    try {
      allFiles = await _lib.checkAllFilesPermission();
    } catch (e) {
      debugPrint('checkAllFilesPermission error: $e');
    }

    permissions.value = MediaPermissionState.fromBools(
      scopedGranted: scoped,
      allFilesGranted: allFiles,
    );
    return permissions.value;
  }

  Future<bool> requestScopedPermission() async {
    await ensureInitialized();
    if (_isNonMobile) return true;

    try {
      final granted = await _lib.requestPermission();
      if (granted) {
        permissions.value = permissions.value.copyWith(
          scoped: MediaPermissionStatus.granted,
        );
      } else {
        permissions.value = permissions.value.copyWith(
          scoped: MediaPermissionStatus.denied,
        );
      }
      return granted;
    } catch (e) {
      debugPrint('requestPermission error: $e');
      return false;
    }
  }

  Future<bool> requestAllFilesPermission() async {
    await ensureInitialized();
    if (_isNonMobile) return true;

    try {
      return await _lib.requestAllFilesPermission();
    } catch (e) {
      debugPrint('requestAllFilesPermission error: $e');
      return false;
    }
  }

  Future<StorageAccessInfo> checkStorageAccess({
    String folder = 'download',
  }) async {
    await ensureInitialized();
    if (_isNonMobile) {
      return StorageAccessInfo.unsupported('Not supported on this platform');
    }
    try {
      final raw = await _lib.checkStorageAccess(folder: folder);
      return StorageAccessInfo.fromMap(raw);
    } catch (e) {
      debugPrint('checkStorageAccess error: $e');
      return StorageAccessInfo.unsupported(e.toString());
    }
  }

  void _attachLifecycle() {
    if (_lifecycleAttached) return;
    try {
      WidgetsFlutterBinding.ensureInitialized();
      WidgetsBinding.instance.addObserver(this);
      _lifecycleAttached = true;
    } catch (e) {
      debugPrint('attachLifecycle error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _pluginInitialized) {
      refresh();
    }
  }

  @visibleForTesting
  void reset() {
    if (_lifecycleAttached) {
      try {
        WidgetsBinding.instance.removeObserver(this);
      } catch (_) {}
      _lifecycleAttached = false;
    }
    _pluginInitialized = false;
    _bootstrapping = null;
    _isNonMobileCached = null;
    permissions.value = const MediaPermissionState();
  }
}

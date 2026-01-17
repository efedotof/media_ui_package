import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_ui_package/media_ui_package.dart';

class CustomVideoPlayerWidget extends StatefulWidget {
  final MediaItem mediaItem;
  final Uint8List thumbnailData;
  final bool isSelected;
  final int selectionIndex;
  final bool autoPlay;

  const CustomVideoPlayerWidget({
    super.key,
    required this.mediaItem,
    required this.thumbnailData,
    this.isSelected = false,
    this.selectionIndex = 0,
    this.autoPlay = false,
  });

  @override
  State<CustomVideoPlayerWidget> createState() =>
      _CustomVideoPlayerWidgetState();
}

class _CustomVideoPlayerWidgetState extends State<CustomVideoPlayerWidget> {
  Widget? _nativeVideoView;
  int? _platformViewId;
  late DeviceMediaLibrary _mediaLibrary;

  @override
  void initState() {
    super.initState();
    _mediaLibrary = DeviceMediaLibrary();
    _createNativeVideoView();
  }

  void _createNativeVideoView() {
    final params = {
      'videoPath': widget.mediaItem.uri,
      'videoUri': widget.mediaItem.uri,
      'autoPlay': widget.autoPlay,
      'volume': 1.0,
    };

    if (Platform.isAndroid) {
      _nativeVideoView = AndroidView(
        viewType: 'device_media_library/video/view',
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          _platformViewId = id;
          debugPrint('✅ AndroidView created with id: $id');

          _initializeVideo();
        },
      );
    } else {
      _nativeVideoView = UiKitView(
        viewType: 'device_media_library/video/view',
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          _platformViewId = id;
          debugPrint('✅ UiKitView created with id: $id');

          _initializeVideo();
        },
      );
    }
  }

  void _initializeVideo() async {
    if (_platformViewId == null) return;

    try {
      await _mediaLibrary.initializeVideo(
        videoPath: widget.mediaItem.uri.startsWith('file://')
            ? widget.mediaItem.uri
            : "",
        videoUri: widget.mediaItem.uri.startsWith('content://')
            ? widget.mediaItem.uri
            : null,
        autoPlay: widget.autoPlay,
        volume: 1.0,
      );

      debugPrint('✅ Video initialized via PlatformView');
    } catch (e) {
      debugPrint('❌ Error initializing video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_nativeVideoView != null)
            Positioned.fill(child: _nativeVideoView!)
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.memory(
                    widget.thumbnailData,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),

          if (widget.isSelected)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.selectionIndex}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mediaLibrary.disposeVideo();
    super.dispose();
  }
}

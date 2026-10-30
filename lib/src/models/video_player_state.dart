enum VideoPlaybackStatus {
  idle,
  initializing,
  ready,
  playing,
  paused,
  buffering,
  completed,
  error;

  bool get isActive =>
      this == VideoPlaybackStatus.playing ||
      this == VideoPlaybackStatus.buffering;
}

class VideoPlayerState {
  final VideoPlaybackStatus status;

  final double position;

  final double duration;
  final double volume;
  final double playbackSpeed;
  final bool isBuffering;
  final String? errorMessage;

  const VideoPlayerState({
    this.status = VideoPlaybackStatus.idle,
    this.position = 0,
    this.duration = 0,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
    this.isBuffering = false,
    this.errorMessage,
  });

  factory VideoPlayerState.initial() => const VideoPlayerState();

  factory VideoPlayerState.error(String message) => VideoPlayerState(
    status: VideoPlaybackStatus.error,
    errorMessage: message,
  );

  double get progress =>
      duration > 0 ? (position / duration).clamp(0.0, 1.0) : 0.0;

  bool get isPlaying => status == VideoPlaybackStatus.playing;
  bool get isPaused => status == VideoPlaybackStatus.paused;
  bool get isReady =>
      status != VideoPlaybackStatus.idle &&
      status != VideoPlaybackStatus.initializing &&
      status != VideoPlaybackStatus.error;

  VideoPlayerState applyEvent(Map<String, dynamic> event) {
    final name = (event['event'] ?? event['type'] ?? event['name'])?.toString();

    switch (name) {
      case 'onPrepared':
        return copyWith(
          status: VideoPlaybackStatus.ready,
          duration: _toDouble(event['duration']) ?? duration,
          position: 0,
          isBuffering: false,
          errorMessage: null,
        );

      case 'onPlaybackUpdate':
        final pos = _toDouble(event['position']);
        final playing = event['isPlaying'] == true;
        return copyWith(
          status: playing
              ? VideoPlaybackStatus.playing
              : VideoPlaybackStatus.paused,
          position: pos ?? position,
          isBuffering: false,
        );

      case 'onBufferingUpdate':
        final buffering =
            event['isBuffering'] == true ||
            event['buffering'] == true ||
            (event['percent'] is num && (event['percent'] as num) < 100);
        return copyWith(
          status: buffering
              ? VideoPlaybackStatus.buffering
              : (isPlaying
                    ? VideoPlaybackStatus.playing
                    : VideoPlaybackStatus.paused),
          isBuffering: buffering,
        );

      case 'onCompleted':
        return copyWith(
          status: VideoPlaybackStatus.completed,
          position: duration,
          isBuffering: false,
        );

      case 'onError':
        return copyWith(
          status: VideoPlaybackStatus.error,
          errorMessage: event['message']?.toString() ?? 'Playback error',
          isBuffering: false,
        );

      case 'onVideoSizeChanged':
        return this;

      default:
        return this;
    }
  }

  VideoPlayerState copyWith({
    VideoPlaybackStatus? status,
    double? position,
    double? duration,
    double? volume,
    double? playbackSpeed,
    bool? isBuffering,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VideoPlayerState(
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isBuffering: isBuffering ?? this.isBuffering,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  String toString() =>
      'VideoPlayerState(status: $status, pos: $position/$duration)';
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

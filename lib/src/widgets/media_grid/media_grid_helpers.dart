String formatDuration(int milliseconds) {
  final d = Duration(milliseconds: milliseconds);
  final minutes = d.inMinutes;
  final seconds = d.inSeconds.remainder(60);
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
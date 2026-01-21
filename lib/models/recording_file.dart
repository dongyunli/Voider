class RecordingFile {
  final String path;
  final String name;
  final DateTime createdAt;
  final int size;
  final Duration? duration; // 可选，如果能从元数据读取

  // 播放相关
  bool isPlaying = false;
  Duration? playbackPosition; // 当前播放位置
  Duration? totalDuration; // 文件总时长

  RecordingFile({
    required this.path,
    required this.name,
    required this.createdAt,
    required this.size,
    this.duration,
    this.isPlaying = false,
    this.playbackPosition,
    this.totalDuration,
  });
}

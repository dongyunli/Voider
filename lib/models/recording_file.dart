/// 录音文件数据模型（纯数据，不包含 UI 状态）
class RecordingFile {
  final String path;
  final String name;
  final DateTime createdAt;
  final int size;
  final Duration? duration; // 可选，如果能从元数据读取

  const RecordingFile({
    required this.path,
    required this.name,
    required this.createdAt,
    required this.size,
    this.duration,
  });

  /// 创建副本（不修改原始对象）
  RecordingFile copyWith({
    String? path,
    String? name,
    DateTime? createdAt,
    int? size,
    Duration? duration,
  }) {
    return RecordingFile(
      path: path ?? this.path,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      size: size ?? this.size,
      duration: duration ?? this.duration,
    );
  }
}

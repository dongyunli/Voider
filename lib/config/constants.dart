class AppConstants {
  // 录音时长选项 (分钟)
  static const List<int> recordingDurations = [3, 5, 10, 15];

  // 无限制录音的标识
  static const int unlimitedDuration = -1;

  // 日期格式
  static const String filenameDateFormat = 'yyyyMMdd_HHmmss';
  static const String displayDateFormat = 'yyyy-MM-dd HH:mm';

  // 时间间隔常量
  static const Duration timerInterval = Duration(seconds: 1);  // ✅ Timer 更新间隔
  static const Duration playbackUpdateInterval = Duration(seconds: 1);  // ✅ 播放位置更新间隔

  // 录音时长限制
  static const int maxRecordingDuration = 120;  // ✅ 最大录音时长（分钟）
  static const int minRecordingDuration = 0;  // ✅ 最小录音时长

  // 响应式断点
  static const int tabletBreakpoint = 600;  // ✅ 平板/桌面断点

  // 文件扩展名
  static const String recordingFileExtension = '.aac';  // ✅ 录音文件扩展名
}

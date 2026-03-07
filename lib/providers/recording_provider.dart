import 'dart:async' as async_lib;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import '../services/audio_recorder_service.dart';
import '../services/file_manager_service.dart';
import '../services/permission_service.dart';
import '../config/constants.dart';
import '../models/recording_file.dart';

/// 播放状态管理类（独立于数据模型）
class PlaybackState {
  final bool isPlaying;
  final Duration? currentPosition;
  final Duration? totalDuration;

  const PlaybackState({
    required this.isPlaying,
    this.currentPosition,
    this.totalDuration,
  });

  PlaybackState copyWith({
    bool? isPlaying,
    Duration? currentPosition,
    Duration? totalDuration,
  }) {
    return PlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}

class RecordingProvider extends ChangeNotifier {
  final AudioRecorderService _recorderService = AudioRecorderService();
  final FileManagerService _fileService = FileManagerService();
  final PermissionService _permissionService = PermissionService();
  final Logger _logger = Logger();

  // ✅ Timer 状态使用 ValueNotifier（性能优化）
  final ValueNotifier<int> _elapsedSecondsNotifier = ValueNotifier(0);

  // 音频播放器
  FlutterSoundPlayer? _player;

  // 状态
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isInitializing = true;
  String? _currentFilePath;

  // 计时器相关
  async_lib.Timer? _timer;
  int _elapsedSeconds = 0;
  int _selectedDurationLimit = AppConstants.unlimitedDuration;

  // 播放计时器
  async_lib.Timer? _playbackTimer;

  // 播放状态管理（独立于数据模型）
  final Map<String, PlaybackState> _playbackStates = {};

  // 文件列表
  List<RecordingFile> _recordings = [];

  // 播放状态
  String? _currentlyPlayingPath;

  // Getters
  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  bool get isInitializing => _isInitializing;
  int get elapsedSeconds => _elapsedSeconds;
  ValueNotifier<int> get elapsedSecondsNotifier => _elapsedSecondsNotifier;  // ✅ 暴露 ValueNotifier
  int get selectedDurationLimit => _selectedDurationLimit;
  List<RecordingFile> get recordings => _recordings;
  bool get isPlaying => _currentlyPlayingPath != null;

  /// 获取指定文件的播放状态
  PlaybackState? getPlaybackState(String path) => _playbackStates[path];
  
  // 初始化
  RecordingProvider() {
    _init();
    _initRecorder();
  }

  void _init() {
    _isInitializing = true;
    loadRecordings();
  }

  void _startTimer() {
    _timer?.cancel();  // 取消旧 timer
    // 不要重置 _elapsedSeconds，恢复录音时应该继续累计
    _timer = async_lib.Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      _elapsedSecondsNotifier.value = _elapsedSeconds;  // ✅ 更新 ValueNotifier 而不触发全局 notifyListeners()

      if (_selectedDurationLimit != AppConstants.unlimitedDuration && _elapsedSeconds >= _selectedDurationLimit * 60) {
        stopRecording();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();  // ✅ 先取消 timer
    _timer = null;     // ✅ 再设置为 null
  }

  // 播放计时器相关
  void _startPlaybackTimer(String path) {
    _playbackTimer?.cancel();

    // ✅ 使用 PlaybackState 对象管理播放状态
    _playbackStates[path] = const PlaybackState(
      isPlaying: true,
      currentPosition: Duration.zero,
    );

    _playbackTimer = async_lib.Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = _playbackStates[path];
      if (currentState != null) {
        _playbackStates[path] = PlaybackState(
          isPlaying: currentState.isPlaying,
          currentPosition: (currentState.currentPosition ?? Duration.zero) + const Duration(seconds: 1),
          totalDuration: currentState.totalDuration,
        );
      }
    });
  }

  void _stopPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }
  
  // 初始化录音器
  Future<void> _initRecorder() async {
    await _recorderService.init();
  }
  
  Future<void> loadRecordings() async {
    _recordings = await _fileService.getRecordings();
    notifyListeners();
  }
  
  Future<void> startRecording() async {
    // 检查权限
    final hasPermission = await _permissionService.requestRecordingPermissions();
    if (!hasPermission) {
      _logger.e("Recording start failed: Permission denied");
      return; // 调用者应显示权限提示
    }

    // 检查可用存储空间（至少需要 10MB）
    final availableSpace = await _getAvailableStorageSpace();
    const minRequiredSpace = 10 * 1024 * 1024; // 10MB
    if (availableSpace != null && availableSpace < minRequiredSpace) {
      _logger.w("Recording start failed: Insufficient storage space. Available: $availableSpace bytes");
      return; // 调用者应显示存储空间不足提示
    }

    _currentFilePath = await _fileService.generateFilePath();
    if (_currentFilePath == null) return;

    try {
      await _recorderService.start(_currentFilePath!);
      _isRecording = true;
      _isPaused = false;
      _isInitializing = false;
      _elapsedSeconds = 0;
      _startTimer();
      notifyListeners();
    } catch (e) {
      _logger.e("Error starting recording: $e");
      _isRecording = false;
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> pauseRecording() async {
    if (!_isRecording || _isPaused) return;
    
    await _recorderService.pause();
    _isPaused = true;
    _stopTimer();
    
    notifyListeners();
  }
  
  Future<void> resumeRecording() async {
    if (!_isRecording || !_isPaused) return;
    
    await _recorderService.resume();
    _isPaused = false;
    _startTimer();
    
    notifyListeners();
  }
  
  Future<void> stopRecording() async {
    if (!_isRecording) return;
    
    await _recorderService.stop();
    await loadRecordings();
    
    _isRecording = false;
    _isPaused = false;
    _stopTimer();
    _elapsedSeconds = 0;  // 停止录音后重置计时器
    
    notifyListeners();
  }
  
  void setDurationLimit(int minutes) {
    // 验证输入范围
    if (minutes < 0) {
      _logger.w("Invalid duration limit: $minutes. Must be >= 0");
      return;  // 拒绝非法输入
    }

    // 验证最大时长
    const maxDuration = AppConstants.maxRecordingDuration;  // 从常量读取
    if (minutes > 0 && minutes != AppConstants.unlimitedDuration && minutes > maxDuration) {
      _logger.w("Duration limit exceeds maximum: $minutes > $maxDuration minutes");
      return;
    }

    if (_selectedDurationLimit == minutes) return;  // 避免不必要的更新

    _selectedDurationLimit = minutes;
    _logger.i("Duration limit set to: $minutes minutes");
    notifyListeners();
  }

  // --- Playback ---
  Future<void> playRecording(String path) async {
    // 如果已经在播放这个文件，则停止
    if (_currentlyPlayingPath == path) {
      await stopPlayback();
      return;
    }

    try {
      // 停止当前播放
      await stopPlayback();

      // 标记正在播放
      _currentlyPlayingPath = path;

      // ✅ 使用 PlaybackState 对象管理播放状态
      _playbackStates[path] = const PlaybackState(
        isPlaying: true,
        currentPosition: Duration.zero,
      );
      notifyListeners();

      // 创建新的播放器
      _player = FlutterSoundPlayer();

      // 初始化播放器
      await _player!.openPlayer();

      // 开始播放并获取时长
      final duration = await _player!.startPlayer(
        fromURI: path,
        // 不指定 codec，让系统自动选择
        whenFinished: () {
          // ✅ 播放完成后清理，使用 PlaybackState 对象
          _stopPlaybackTimer();
          _playbackStates[path] = PlaybackState(
            isPlaying: false,
            totalDuration: _playbackStates[path]?.totalDuration,
          );
          _currentlyPlayingPath = null;
          notifyListeners();
        },
      );

      // 设置文件总时长到 PlaybackState
      if (duration != null) {
        _playbackStates[path] = PlaybackState(
          isPlaying: true,
          currentPosition: _playbackStates[path]?.currentPosition,
          totalDuration: duration,
        );
      }

      // 启动播放计时器
      _startPlaybackTimer(path);

      notifyListeners();
    } catch (e) {
      _logger.e("Error playing recording: $e");  // ✅ 统一使用 Logger
      _currentlyPlayingPath = null;
      _playbackStates[path] = const PlaybackState(
        isPlaying: false,
      );
      notifyListeners();
    }
  }

  Future<void> stopPlayback() async {
    if (_player == null) return;

    try {
      await _player!.stopPlayer();
      await _player!.closePlayer();
      _player = null;

      // ✅ 恢复所有播放状态，使用 PlaybackState 对象
      for (var i = 0; i < _recordings.length; i++) {
        _playbackStates[_recordings[i].path] = const PlaybackState(
          isPlaying: false,
        );
      }
      _currentlyPlayingPath = null;

      notifyListeners();
    } catch (e) {
      _logger.e("Error stopping playback: $e");  // ✅ 统一使用 Logger
      _player = null;

      // 恢复所有播放状态
      for (var i = 0; i < _recordings.length; i++) {
        _playbackStates[_recordings[i].path] = const PlaybackState(
          isPlaying: false,
        );
      }
      _currentlyPlayingPath = null;
      notifyListeners();
    }
  }

  Future<void> deleteRecording(String path) async {
    await _fileService.deleteFile(path);
    await loadRecordings();
  }

  /// 检查可用存储空间
  /// 返回可用字节数，如果检查失败返回 null
  Future<int?> _getAvailableStorageSpace() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final stat = await directory.stat();
      if (stat.type == FileSystemEntityType.file) {
        final file = File(directory.path);
        final parent = file.parent;
        if (await parent.exists()) {
          final parentStat = await parent.stat();
          return parentStat.size;
        }
      }
      // 如果是目录，尝试获取父目录信息
      final parent = directory.parent;
      if (await parent.exists()) {
        final parentStat = await parent.stat();
        return parentStat.size;
      }
      return null;
    } catch (e) {
      _logger.e("Error checking storage space: $e");
      return null;
    }
  }

  @override
  void dispose() {
    // 清理播放器资源（使用 try-catch 确保安全）
    try {
      if (_player != null) {
        _player!.stopPlayer();
        _player!.closePlayer();
      }
    } catch (e) {
      _logger.e("Error in stopPlayback during dispose: $e");  // ✅ 添加错误日志
    } finally {
      _player = null;  // ✅ 确保 _player 被设置为 null
    }

    // 清理录制器资源
    _recorderService.dispose();
    _timer?.cancel();
    _playbackTimer?.cancel();
    _elapsedSecondsNotifier.dispose();  // ✅ 清理 ValueNotifier

    super.dispose();
  }
}

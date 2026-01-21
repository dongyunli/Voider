import 'dart:async' as async_lib;
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../services/audio_recorder_service.dart';
import '../services/file_manager_service.dart';
import '../services/permission_service.dart';
import '../config/constants.dart';
import '../models/recording_file.dart';

class RecordingProvider extends ChangeNotifier {
  final AudioRecorderService _recorderService = AudioRecorderService();
  final FileManagerService _fileService = FileManagerService();
  final PermissionService _permissionService = PermissionService();
  
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
  Duration _playbackPosition = Duration.zero;
  
  // 文件列表
  List<RecordingFile> _recordings = [];
  
  // 播放状态
  String? _currentlyPlayingPath;
  
  // Getters
  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  bool get isInitializing => _isInitializing;
  int get elapsedSeconds => _elapsedSeconds;
  int get selectedDurationLimit => _selectedDurationLimit;
  List<RecordingFile> get recordings => _recordings;
  bool get isPlaying => _currentlyPlayingPath != null;
  
  // 初始化
  RecordingProvider() {
    _init();
    _initRecorder();
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
    final hasPermission = await _permissionService.requestRecordingPermissions();
    if (!hasPermission) return;
    
    _currentFilePath = await _fileService.generateFilePath();
    if (_currentFilePath == null) return;
    await _recorderService.start(_currentFilePath!);
    
    _isRecording = true;
    _isPaused = false;
    _isInitializing = false;
    _elapsedSeconds = 0;
    _startTimer();
    
    notifyListeners();
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
    if (_selectedDurationLimit == minutes) return;
    _selectedDurationLimit = minutes;
    notifyListeners();
  }
  
  void _startTimer() {
    _timer?.cancel();
    // 不要重置 _elapsedSeconds，恢复录音时应该继续累计
    _timer = async_lib.Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      if (_selectedDurationLimit != AppConstants.unlimitedDuration && _elapsedSeconds >= _selectedDurationLimit * 60) {
        stopRecording();
      }
      notifyListeners();
    });
  }
  
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // 播放计时器相关
  void _startPlaybackTimer(String path) {
    _playbackTimer?.cancel();
    _playbackPosition = Duration.zero;

    _playbackTimer = async_lib.Timer.periodic(const Duration(seconds: 1), (timer) {
      _playbackPosition = _playbackPosition + const Duration(seconds: 1);

      // 更新对应文件的播放位置
      for (var i = 0; i < _recordings.length; i++) {
        if (_recordings[i].path == path) {
          _recordings[i].playbackPosition = _playbackPosition;
          notifyListeners();
          break;
        }
      }
    });
  }

  void _stopPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    _playbackPosition = Duration.zero;
  }
  
  void _init() {
    _isInitializing = true;
    loadRecordings();
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

      // 更新录音列表中的播放状态（暂不设置时长，等播放开始后再获取）
      for (var i = 0; i < _recordings.length; i++) {
        if (_recordings[i].path == path) {
          _recordings[i].isPlaying = true;
          _recordings[i].playbackPosition = Duration.zero;
        } else {
          _recordings[i].isPlaying = false;
        }
      }
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
          // 播放完成后清理
          _stopPlaybackTimer();
          for (var i = 0; i < _recordings.length; i++) {
            if (_recordings[i].path == path) {
              _recordings[i].isPlaying = false;
              _recordings[i].playbackPosition = null;
              _recordings[i].totalDuration = null;
            }
          }
          _currentlyPlayingPath = null;
          notifyListeners();
        },
      );

      // 设置文件总时长
      if (duration != null) {
        for (var i = 0; i < _recordings.length; i++) {
          if (_recordings[i].path == path) {
            _recordings[i].totalDuration = duration;
            break;
          }
        }
      }

      // 启动播放计时器
      _startPlaybackTimer(path);

      notifyListeners();
    } catch (e) {
      print("Error playing recording: $e");
      _currentlyPlayingPath = null;
      for (var i = 0; i < _recordings.length; i++) {
        if (_recordings[i].path == path) {
          _recordings[i].isPlaying = false;
        }
      }
      notifyListeners();
    }
  }
  
  Future<void> stopPlayback() async {
    if (_player == null) return;
    
    try {
      await _player!.stopPlayer();
      await _player!.closePlayer();
      _player = null;
      
      // 恢复所有播放状态
      for (var i = 0; i < _recordings.length; i++) {
        _recordings[i].isPlaying = false;
        _recordings[i].playbackPosition = null;
        _recordings[i].totalDuration = null;
      }
      _currentlyPlayingPath = null;
      
      notifyListeners();
    } catch (e) {
      print("Error stopping playback: $e");
      _player = null;
      
      // 恢复所有播放状态
      for (var i = 0; i < _recordings.length; i++) {
        _recordings[i].isPlaying = false;
      }
      _currentlyPlayingPath = null;
      notifyListeners();
    }
  }
  
  Future<void> deleteRecording(String path) async {
    await _fileService.deleteFile(path);
    await loadRecordings();
  }
  
  @override
  void dispose() {
    _recorderService.dispose();
    _timer?.cancel();
    // 清理播放器
    stopPlayback();
    super.dispose();
  }
}

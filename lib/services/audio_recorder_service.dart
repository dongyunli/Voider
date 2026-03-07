import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:logger/logger.dart';

class AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final Logger _logger = Logger();

  Future<void> init() async {
    try {
      await _recorder.openRecorder();
      _logger.i("AudioRecorder initialized successfully");
    } catch (e) {
      _logger.e("Error initializing recorder: $e");
      rethrow;
    }
  }

  Future<void> start(String path) async {
    try {
      await _recorder.startRecorder(
        toFile: path,
        // 不指定编码器，让系统自动选择最合适的
      );
    } catch (e) {
      _logger.e("Error starting recording: $e");
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await _recorder.stopRecorder();
      _logger.i("Recorder stopped successfully");
    } catch (e) {
      _logger.e("Error stopping recorder: $e");
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _recorder.pauseRecorder();
      _logger.i("Recorder paused successfully");
    } catch (e) {
      _logger.e("Error pausing recorder: $e");
      rethrow;
    }
  }

  Future<void> resume() async {
    try {
      await _recorder.resumeRecorder();
      _logger.i("Recorder resumed successfully");
    } catch (e) {
      _logger.e("Error resuming recorder: $e");
      rethrow;
    }
  }

  Future<void> dispose() async {
    try {
      await _recorder.closeRecorder();
      _logger.i("Recorder closed successfully");
    } catch (e) {
      _logger.e("Error closing recorder: $e");
      rethrow;
    }
  }

  Future<bool> isRecording() async {
    try {
      return _recorder.isRecording;
    } catch (e) {
      _logger.e("Error checking recording state: $e");
      return false;
    }
  }
}

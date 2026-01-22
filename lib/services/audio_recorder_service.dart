import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:logger/logger.dart';

class AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final Logger _logger = Logger();

  Future<void> init() async {
    await _recorder.openRecorder();
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
    await _recorder.stopRecorder();
  }

  Future<void> pause() async {
    await _recorder.pauseRecorder();
  }

  Future<void> resume() async {
    await _recorder.resumeRecorder();
  }

  Future<void> dispose() async {
    await _recorder.closeRecorder();
  }

  Future<bool> isRecording() async {
    return _recorder.isRecording;
  }
}
